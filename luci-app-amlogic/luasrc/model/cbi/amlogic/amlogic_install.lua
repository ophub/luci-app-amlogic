local fs = require "luci.fs"
local http = require "luci.http"
local DISP = require "luci.dispatcher"
local m, c, mlog

--SimpleForm for nil
m = SimpleForm("", "", nil)
m.reset = false
m.submit = false

--SimpleForm for Install OpenWrt to Amlogic EMMC
c = Map("amlogic_install")
c.title = translate("Install OpenWrt")
c.description = translate("Install OpenWrt to Amlogic EMMC, Please Select the Amlogic SoC, Or enter the dtb file name.")
c.pageaction = false

c:section(SimpleSection).template  = "amlogic/other_install"



--SimpleForm for Server Logs
mlog = SimpleForm("amlogic_log", translate("Server Logs"), nil)
mlog.reset = false
mlog.submit = false
slog = mlog:section(SimpleSection, "", translate("Display the execution log of the current operation."))
olog = slog:option(TextValue, "")
olog.template = "amlogic/other_log"

return m, c, mlog
