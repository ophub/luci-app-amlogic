local fs = require "luci.fs"
local http = require "luci.http"
local DISP = require "luci.dispatcher"
local m, b, c

local default_plugin_url = "https://raw.githubusercontent.com/ophub/luci-app-amlogic/main/CHECK"
local default_kernel_url = "https://raw.githubusercontent.com/ophub/luci-app-amlogic/main/CHECK"
local amlogic_plugin_url = luci.sys.exec("uci get amlogic.config.amlogic_plugin_url 2>/dev/null") or default_plugin_url
local amlogic_kernel_url = luci.sys.exec("uci get amlogic.config.amlogic_kernel_url 2>/dev/null") or default_kernel_url

--SimpleForm for nil
m = SimpleForm("", "", nil)
m.reset = false
m.submit = false

--SimpleForm for Config Source
b = SimpleForm("amlogic_check", translate("Config Source"), nil)
b.description = translate("You can customize the storage site for OpenWrt kernel and plugin according to your needs.")
b.reset = false
b.submit = false
s = b:section(SimpleSection, "", "")

--1.Kernel
o = s:option(Value, "amlogic_kernel", translate("Kernel Website:"))
o.rmempty = true
o.default = amlogic_kernel_url
o.write = function(self, key, value)
	if value == "" then
        --self.description = translate("Invalid value.")
        amlogic_kernel_url = default_kernel_url
	else
        --self.description = translate("Use custom kernel url:") .. value
        amlogic_kernel_url = value
	end
end

--2.Plugin
o = s:option(Value, "amlogic_plugin", translate("Plugin Website:"))
o.rmempty = true
o.default = amlogic_plugin_url
o.write = function(self, key, value)
	if value == "" then
        --self.description = translate("Invalid value.")
        amlogic_plugin_url = default_plugin_url
	else
        --self.description = translate("Use custom Plugin url:") .. value
        amlogic_plugin_url = value
	end
end

--3.Save button
o = s:option(Button, "", translate("Save Config:"))
o.template = "amlogic/other_button"
o.render = function(self, section, scope)
	self.section = true
	scope.display = ""
	self.inputtitle = translate("Save")
	self.inputstyle = "apply"
	Button.render(self, section, scope)
end
o.write = function(self, section, scope)
	if not emmc_dtb then
	    emmc_dtb = "no"
	end
	luci.sys.exec("uci set amlogic.config.amlogic_plugin_url=" .. amlogic_plugin_url .. " 2>/dev/null")
	luci.sys.exec("uci set amlogic.config.amlogic_kernel_url=" .. amlogic_kernel_url .. " 2>/dev/null")
	luci.sys.exec("uci commit amlogic 2>/dev/null")
	http.redirect(DISP.build_url("admin", "system", "amlogic", "check"))
	--self.description = "amlogic_plugin_url: " .. amlogic_plugin_url .. " amlogic_kernel_url: " .. amlogic_kernel_url
end

--SimpleForm for Check
c = Map("amlogic")
c.title = translate("Check Update")
c.description = translate("Provide OpenWrt Kernel and Plugin online check and update service.")
c.pageaction = false

c:section(SimpleSection).template  = "amlogic/other_check"


return m, b, c
