local fs = require "luci.fs"
local http = require "luci.http"
local DISP = require "luci.dispatcher"
local m

--SimpleForm for Info
m = Map("amlogic")
m.title = translate("OpenWrt for Amlogic S9xxx STB")
m.description = translate("Provide services such as install to EMMC, Update Firmware or Kernel, Backup and Recovery Config for Amlogic STB.")
m.pageaction = false

m:section(SimpleSection).template  = "amlogic/other_info"

return m
