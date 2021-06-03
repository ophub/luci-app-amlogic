local fs = require "luci.fs"
local http = require "luci.http"
local DISP = require "luci.dispatcher"
local m, mlog

--SimpleForm for nil
m = SimpleForm("", "", nil)
m.reset = false
m.submit = false

--SimpleForm for Server Logs
mlog = SimpleForm("amlogic_log", translate("Server Logs"), nil)
mlog.reset = false
mlog.submit = false
slog = mlog:section(SimpleSection, "", translate("Display the execution log of the current operation."))
olog = slog:option(TextValue, "")
olog.template = "amlogic/other_log"

return m, mlog
