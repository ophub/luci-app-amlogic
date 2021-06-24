local fs = require "luci.fs"
local http = require "luci.http"
local DISP = require "luci.dispatcher"
local m, c

--SimpleForm for nil
m = SimpleForm("", "", nil)
m.reset = false
m.submit = false

--8.SimpleForm for Check
c = Map("amlogic")
c.title = translate("Check Update")
c.description = translate("Provide OpenWrt Firmware, Kernel and Plugin online check, download and update service.")
c.pageaction = false
c:section(SimpleSection).template  = "amlogic/other_check"

return m, c
