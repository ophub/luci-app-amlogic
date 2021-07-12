local fs = require "luci.fs"
local http = require "luci.http"
local DISP = require "luci.dispatcher"
local b

--SimpleForm for Info
b = SimpleForm("amlogic", translate("Amlogic Service"), nil)
b.description = translate("Provide services such as install to EMMC, Update Firmware or Kernel, Backup and Recovery Config for Amlogic STB.")
b.reset = false
b.submit = false
b:section(SimpleSection).template  = "amlogic/other_info"


return b

