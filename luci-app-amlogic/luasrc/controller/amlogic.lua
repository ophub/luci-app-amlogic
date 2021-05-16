module("luci.controller.amlogic", package.seeall)

function index()

    page = entry({"admin", "system", "amlogic"}, alias("admin", "system", "amlogic", "info"), _("Amlogic Service"), 88)
    page.dependent = true
    entry({"admin", "system", "amlogic", "info"},cbi("amlogic/amlogic_info"),_("Amlogic Service"), 1).leaf = true
    entry({"admin", "system", "amlogic", "install"},cbi("amlogic/amlogic_install"),_("Install OpenWrt"), 2).leaf = true
    entry({"admin", "system", "amlogic", "backup"},cbi("amlogic/amlogic_backup"),_("Backup Config"), 3).leaf = true
    entry({"admin", "system", "amlogic", "upload"},cbi("amlogic/amlogic_upload"),_("Restore Config / Replace OpenWrt Kernel"), 4).leaf = true
    entry({"admin", "system", "amlogic", "check"},cbi("amlogic/amlogic_check"),_("Config and Update"), 5).leaf = true
    entry({"admin", "system", "amlogic", "check_plugin"},call("action_check_plugin"))
    entry({"admin", "system", "amlogic", "check_kernel"},call("action_check_kernel"))
    entry({"admin", "system", "amlogic", "refresh_log"},call("action_refresh_log"))
    entry({"admin", "system", "amlogic", "del_log"},call("action_del_log"))
    entry({"admin", "system", "amlogic", "start_check_plugin"},call("action_start_check_plugin")).leaf=true
    entry({"admin", "system", "amlogic", "start_check_kernel"},call("action_start_check_kernel")).leaf=true
    entry({"admin", "system", "amlogic", "state"},call("action_state")).leaf=true

end

local fs = require "luci.fs"

function action_refresh_log()
    local logfile="/tmp/amlogic/amlogic.log"
    if not fs.access(logfile) then
        --luci.http.write(os.date() .. ": No log")
        luci.sys.exec("mkdir -p /tmp/amlogic && sync")
        luci.sys.exec("uname -a > /tmp/amlogic/amlogic.log && sync")
        luci.sys.exec("echo '' > /tmp/amlogic/amlogic_check_plugin.log && sync >/dev/null 2>&1")
        luci.sys.exec("echo '' > /tmp/amlogic/amlogic_check_kernel.log && sync >/dev/null 2>&1")
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
    luci.sys.exec(": > /tmp/amlogic/amlogic.log")
    return
end

function action_check_plugin()
    luci.sys.exec("chmod +x /usr/share/amlogic/amlogic_check_plugin.sh >/dev/null 2>&1")
    return luci.sys.call("/usr/share/amlogic/amlogic_check_plugin.sh >/dev/null 2>&1")
end

function action_check_kernel()
    luci.sys.exec("chmod +x /usr/share/amlogic/amlogic_check_kernel.sh >/dev/null 2>&1")
    return luci.sys.call("/usr/share/amlogic/amlogic_check_kernel.sh >/dev/null 2>&1")
end


local function start_check_plugin()
    return luci.sys.exec("sed -n '$p' /tmp/amlogic/amlogic_check_plugin.log 2>/dev/null")
end

local function start_check_kernel()
    return luci.sys.exec("sed -n '$p' /tmp/amlogic/amlogic_check_kernel.log 2>/dev/null")
end

function action_start_check_plugin()
    luci.http.prepare_content("application/json")
    luci.http.write_json({
        start_check_plugin = start_check_plugin();
    })
end

function action_start_check_kernel()
    luci.http.prepare_content("application/json")
    luci.http.write_json({
        start_check_kernel = start_check_kernel();
    })
end

local function current_plugin_version()
    return luci.sys.exec("uci get amlogic.config.amlogic_plugin_version 2>/dev/null") or "Invalid value."
end

local function current_kernel_version()
    --return luci.sys.exec("uci get amlogic.config.amlogic_kernel_version 2>/dev/null") or "Invalid value."
    return luci.sys.exec("ls /lib/modules/  2>/dev/null | grep -oE '^[1-9].[0-9]{1,2}.[0-9]+'")
end

function action_state()
    luci.http.prepare_content("application/json")
    luci.http.write_json({
        current_plugin_version = current_plugin_version(),
        current_kernel_version = current_kernel_version();
    })
end
