module("luci.controller.amlogic", package.seeall)

function index()

    page = entry({"admin", "system", "amlogic"}, alias("admin", "system", "amlogic", "info"), _("Amlogic Service"), 88)
    page.dependent = true
    entry({"admin", "system", "amlogic", "info"},cbi("amlogic/amlogic_info"),_("Amlogic Service"), 1).leaf = true
    entry({"admin", "system", "amlogic", "install"},cbi("amlogic/amlogic_install"),_("Install OpenWrt"), 2).leaf = true
    entry({"admin", "system", "amlogic", "backup"},cbi("amlogic/amlogic_backup"),_("Backup Config"), 3).leaf = true
    entry({"admin", "system", "amlogic", "upload"},cbi("amlogic/amlogic_upload"),_("Restore Config / Replace OpenWrt Kernel"), 4).leaf = true
	entry({"admin", "system", "amlogic", "refresh_log"},call("action_refresh_log"))
	entry({"admin", "system", "amlogic", "del_log"},call("action_del_log"))

end

local fs = require "luci.fs"

function action_refresh_log()
	local logfile="/tmp/amlogic.log"
	if not fs.access(logfile) then
		--luci.http.write(os.date() .. ": No log")
		luci.sys.exec("cat /proc/version > /tmp/amlogic.log && sync")
		--return
	end
	luci.http.prepare_content("text/plain; charset=utf-8")
	local f=io.open(logfile, "r+")
	f:seek("set")
	local a=f:read(2048000) or ""
	f:close()
	luci.http.write(a)
end

function action_del_log()
	luci.sys.exec(": > /tmp/amlogic.log")
	return
end
