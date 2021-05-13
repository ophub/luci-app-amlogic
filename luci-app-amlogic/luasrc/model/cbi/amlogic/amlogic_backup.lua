local fs = require "luci.fs"
local http = require "luci.http"
local DISP = require "luci.dispatcher"
local m, b, mlog

--SimpleForm for Install OpenWrt to EMMC
m = SimpleForm("", "", nil)
m.reset = false
m.submit = false


--SimpleForm for Backup Config
b = SimpleForm("backup", translate("Backup Config"), nil)
b.description = translate("Backup Config (openwrt_config.tar.gz) for Amlogic OpenWrt. You can [upload] this file, and the [Restore Config] button will be displayed in the [Upload file list].")
b.reset = false
b.submit = false
s = b:section(SimpleSection, "", "")
o = s:option(Button, "", translate("Backup Config"))
o.template = "amlogic/other_button"
o.render = function(self, section, scope)
	self.section = true
	scope.display = ""
	self.inputtitle = translate("Backup")
	self.inputstyle = "apply"
	Button.render(self, section, scope)
end

o.write = function(self, section, scope)

	local x = luci.sys.exec("chmod +x /usr/bin/openwrt-backup 2>/dev/null")
	local r = luci.sys.exec("/usr/bin/openwrt-backup -b > /tmp/amlogic.log && sync 2>/dev/null")

	local sPath, sFile, fd, block
	sPath = "/.reserved/openwrt_config.tar.gz"
	sFile = nixio.fs.basename(sPath)
	if luci.fs.isdirectory(sPath) then
		fd = io.popen('tar -C "%s" -cz .' % {sPath}, "r")
		sFile = sFile .. ".tar.gz"
	else
		fd = nixio.open(sPath, "r")
	end
	if not fd then
		backupm.value = translate("Couldn't open file:") .. sPath
		return
	else
        backupm.value = translate("The file Will download automatically.") .. sPath
	end

	http.header('Content-Disposition', 'attachment; filename="%s"' % {sFile})
	http.prepare_content("application/octet-stream")
	while true do
		block = fd:read(nixio.const.buffersize)
		if (not block) or (#block ==0) then
			break
		else
			http.write(block)
		end
	end
	fd:close()
	http.close()
end
backupm = s:option(DummyValue, "", nil)
backupm.template = "amlogic/other_dvalue"

--SimpleForm for Server Logs
mlog = SimpleForm("amlogic_log", translate("Server Logs"), nil)
mlog.reset = false
mlog.submit = false
slog = mlog:section(SimpleSection, "", translate("Display the execution log of the current operation."))
olog = slog:option(TextValue, "")
olog.template = "amlogic/other_log"


return m, b, mlog
