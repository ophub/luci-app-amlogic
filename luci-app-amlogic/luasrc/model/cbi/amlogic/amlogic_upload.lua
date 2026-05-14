-- SPDX-License-Identifier: GPL-2.0
-- Upload and Install Files (Lua CBI model)
--
-- Purpose: accept firmware/kernel/IPK/backup uploads, list staged files in the
-- upload directory, and trigger install/restore actions via openwrt-backup or opkg/apk.

local os    = require "os"
local fs    = require "nixio.fs"
local nutil = require "nixio.util"
local type  = type
local b, form

-- Strip all whitespace from a string.
function trim(str)
	--return (string.gsub(str, "^%s*(.-)%s*$", "%1"))
	return (string.gsub(str, "%s+", ""))
end

-- Expand a shell glob pattern and return all matching paths as a table.
function glob(...)
	local iter, code, msg = fs.glob(...)
	if iter then
		return nutil.consume(iter)
	else
		return nil, code, msg
	end
end

-- Checks whether the given path exists and points to a regular file.
function isfile(filename)
	return fs.stat(filename, "type") == "reg"
end

-- Get the last modification time of given file path in Unix epoch format.
function mtime(path)
	return fs.stat(path, "mtime")
end

local stat_tr = {
	reg = "regular",
	dir = "directory",
	lnk = "link",
	chr = "character device",
	blk = "block device",
	fifo = "fifo",
	sock = "socket"
}
-- Get information about given file or directory.
function stat(path, key)
	local data, code, msg = fs.stat(path)
	if data then
		data.mode = data.modestr
		data.type = stat_tr[data.type] or "?"
	end
	return key and data and data[key] or data, code, msg
end

-- Detect upload destination: shared data partition derived from the root device.
local ROOT_PTNAME = trim(luci.sys.exec("df / | tail -n1 | awk '{print $1}' | awk -F '/' '{print $3}'"))
if ROOT_PTNAME then
	if (string.find(ROOT_PTNAME, "mmcblk[0-4]p[1-4]")) then
		local EMMC_NAME = trim(luci.sys.exec("echo " .. ROOT_PTNAME .. " | awk '{print substr($1, 1, length($1)-2)}'"))
		upload_path = trim("/mnt/" .. EMMC_NAME .. "p4/")
	elseif (string.find(ROOT_PTNAME, "[hsv]d[a-z]")) then
		local EMMC_NAME = trim(luci.sys.exec("echo " .. ROOT_PTNAME .. " | awk '{print substr($1, 1, length($1)-1)}'"))
		upload_path = trim("/mnt/" .. EMMC_NAME .. "4/")
	else
		upload_path = "/tmp/upload/"
	end
else
	upload_path = "/tmp/upload/"
end

-- Clear stale check logs from any previous session.
luci.sys.exec("echo '' > /tmp/amlogic/amlogic_check_plugin.log && sync >/dev/null 2>&1")
luci.sys.exec("echo '' > /tmp/amlogic/amlogic_check_kernel.log && sync >/dev/null 2>&1")

-- SimpleForm for file upload input.
b = SimpleForm("upload", nil)
b.title = translate("Upload")
local des_content = translate("Update plugins first, then update the kernel or firmware.")
local des_content = des_content .. "<br />" .. translate("After uploading [Firmware], [Kernel], [IPK] or [Backup Config], the operation buttons will be displayed.")
b.description = des_content
b.reset = false
b.submit = false

s = b:section(SimpleSection, "", "")

o = s:option(FileUpload, "")
o.template = "amlogic/other_upload"

um = s:option(DummyValue, "", nil)
um.template = "amlogic/other_dvalue"

local dir, fd
dir = upload_path
fs.mkdir(dir)
luci.http.setfilehandler(
	function(meta, chunk, eof)
	if not fd then
		if not meta then return end
		if meta and chunk then fd = nixio.open(dir .. meta.file, "w") end
		if not fd then
			um.value = translate("Create upload file error.") .. " Error Info: " .. trim(upload_path .. meta.file)
			return
		end
	end
	if chunk and fd then
		fd:write(chunk)
	end
	if eof and fd then
		fd:close()
		fd = nil
		um.value = translate("File saved to") .. trim(upload_path .. meta.file)
	end
end
)

if luci.http.formvalue("upload") then
	local f = luci.http.formvalue("ulfile")
	if #f <= 0 then
		um.value = translate("No specify upload file.")
	end
end

local function getSizeStr(size)
	local i = 0
	local byteUnits = { ' kB', ' MB', ' GB', ' TB' }
	repeat
		size = size / 1024
		i = i + 1
	until (size <= 1024)
	return string.format("%.1f", size) .. byteUnits[i]
end

-- Scan the upload directory; classify each file by type for action buttons.
local inits, attr = {}
for i, f in ipairs(glob(trim(upload_path .. "*"))) do
	attr = stat(f)
	itisfile = isfile(f)
	if attr and itisfile then
		inits[i] = {}
		inits[i].name = fs.basename(f)
		inits[i].mtime = os.date("%Y-%m-%d %H:%M:%S", attr.mtime)
		inits[i].modestr = attr.modestr
		inits[i].size = getSizeStr(attr.size)
		inits[i].remove = 0
		inits[i].ipk = false

		-- Detect firmware image files (.img.gz / .img.xz / .7z / .img).
		if (string.lower(string.sub(fs.basename(f), -7, -1)) == ".img.gz") then
			openwrt_firmware_file = true
		end
		if (string.lower(string.sub(fs.basename(f), -7, -1)) == ".img.xz") then
			openwrt_firmware_file = true
		end
		if (string.lower(string.sub(fs.basename(f), -3, -1)) == ".7z") then
			openwrt_firmware_file = true
		end
		if (string.lower(string.sub(fs.basename(f), -4, -1)) == ".img") then
			openwrt_firmware_file = true
		end

		-- Detect kernel tarballs (boot- / dtb- / modules- prefixes).
		if (string.lower(string.sub(fs.basename(f), 1, 5)) == "boot-") then
			boot_file = true
		end
		if (string.lower(string.sub(fs.basename(f), 1, 4)) == "dtb-") then
			dtb_file = true
		end
		if (string.lower(string.sub(fs.basename(f), 1, 8)) == "modules-") then
			modules_file = true
		end

		-- Detect config backup tarball (openwrt_config.tar.gz).
		if (string.lower(string.sub(fs.basename(f), 1, -1)) == "openwrt_config.tar.gz") then
			backup_config_file = true
		end
	end
end

-- SimpleForm for upload file list table.
form = SimpleForm("filelist", translate("Upload file list"), nil)
form.reset = false
form.submit = false

description_info = ""
luci.sys.exec("echo '' > /tmp/amlogic/amlogic_check_upfiles.log && sync >/dev/null 2>&1")

if backup_config_file then
	description_info = description_info .. translate("There are config file in the upload directory, and you can restore the config. ")
end

if boot_file and dtb_file and modules_file then
	description_info = description_info .. translate("There are kernel files in the upload directory, and you can replace the kernel.")
	luci.sys.exec("echo 'kernel' > /tmp/amlogic/amlogic_check_upfiles.log && sync >/dev/null 2>&1")
end

if openwrt_firmware_file then
	description_info = description_info .. translate("There are openwrt firmware file in the upload directory, and you can update the openwrt.")
	luci.sys.exec("echo 'firmware' > /tmp/amlogic/amlogic_check_upfiles.log && sync >/dev/null 2>&1")
end

if description_info ~= "" then
	form.description = ' <span style="color: green"><b> Tip: ' .. description_info .. ' </b></span> '
end

tb = form:section(Table, inits)
nm = tb:option(DummyValue, "name", translate("File name"))
mt = tb:option(DummyValue, "mtime", translate("Modify time"))
ms = tb:option(DummyValue, "modestr", translate("Attributes"))
sz = tb:option(DummyValue, "size", translate("Size"))
btnrm = tb:option(Button, "remove", translate("Remove"))
btnrm.render = function(self, section, scope)
	self.inputstyle = "remove"
	Button.render(self, section, scope)
end
btnrm.write = function(self, section)
	local v = fs.unlink(trim(upload_path .. fs.basename(inits[section].name)))
	if v then table.remove(inits, section) end
	return v
end

function IsConfigFile(name)
	name = name or ""
	local config_file = string.lower(string.sub(name, 1, -1))
	return config_file == "openwrt_config.tar.gz"
end

-- Check if the file is a known package type (.ipk or .apk)
function IsPackageFile(name)
	name = name or ""
	local lname = string.lower(name)
	return string.sub(lname, -4) == ".ipk" or string.sub(lname, -4) == ".apk"
end

-- Install/Restore button: shown for .ipk/.apk packages and config backups.
btnis = tb:option(Button, "ipk", translate("Install"))
btnis.template = "amlogic/other_button"
btnis.render = function(self, section, scope)
	if not inits[section] then return false end
	if IsPackageFile(inits[section].name) then
		scope.display = ""
		self.inputtitle = translate("Install")
	elseif IsConfigFile(inits[section].name) then
		scope.display = ""
		self.inputtitle = translate("Restore")
	else
		scope.display = "none"
	end

	self.inputstyle = "apply"
	Button.render(self, section, scope)
end
btnis.write = function(self, section)
	local file_to_install = inits[section].name
	local full_path = upload_path .. file_to_install

	if IsPackageFile(file_to_install) then
		local r = ""
		local install_cmd = ""

		-- Check for opkg first
		if luci.sys.call("command -v opkg >/dev/null") == 0 then
			install_cmd = string.format('opkg --force-reinstall install %s', full_path)
			r = luci.sys.exec(install_cmd)
		-- Fall back to apk
		elseif luci.sys.call("command -v apk >/dev/null") == 0 then
			-- --allow-untrusted is required for local packages
			install_cmd = string.format('apk add --force-overwrite --allow-untrusted %s', full_path)
			r = luci.sys.exec(install_cmd)
		else
			r = "Error: Neither 'opkg' nor 'apk' package manager found on the system."
		end

		-- Clear LuCI cache after installation.
		luci.sys.exec("rm -rf /tmp/luci-indexcache /tmp/luci-modulecache/* >/dev/null 2>&1")

		-- Show result; prompt user to refresh for changes to take effect.
		local result_msg = r .. "<br/><b>" .. translate("Please refresh the page to see the changes.") .. "</b>"
		form.description = string.format('<span style="color: red">%s</span>', result_msg)

	elseif IsConfigFile(inits[section].name) then
		form.description = ' <span style="color: green"><b> ' .. translate("Tip: The config is being restored, and it will automatically restart after completion.") .. ' </b></span> '
		luci.sys.exec("chmod +x /usr/sbin/openwrt-backup 2>/dev/null")
		luci.sys.exec("/usr/sbin/openwrt-backup -r > /tmp/amlogic/amlogic.log && sync 2>/dev/null")
	end
end

-- Section delegated to other_upfiles template for kernel/firmware action buttons.
form:section(SimpleSection).template = "amlogic/other_upfiles"

return b, form
