local fs = require "luci.fs"
local http = require "luci.http"
local DISP = require "luci.dispatcher"
local m, b, c

local amlogic_plugin_version = "0.1.0"
local default_plugin_url = "https://github.com/ophub/luci-app-amlogic"
local amlogic_kernel_version = "5.4.118"
local default_kernel_url = "https://github.com/ophub/amlogic-s9xxx-openwrt"
local amlogic_plugin_version = luci.sys.exec("uci get amlogic.config.amlogic_plugin_version 2>/dev/null") or default_plugin_url
local amlogic_plugin_url = luci.sys.exec("uci get amlogic.config.amlogic_plugin_url 2>/dev/null") or default_plugin_url
local amlogic_kernel_version = luci.sys.exec("uci get amlogic.config.amlogic_kernel_version 2>/dev/null") or default_kernel_url
local amlogic_kernel_url = luci.sys.exec("uci get amlogic.config.amlogic_kernel_url 2>/dev/null") or default_kernel_url

--SimpleForm for nil
m = SimpleForm("", "", nil)
m.reset = false
m.submit = false


--SimpleForm for Config Source
b = SimpleForm("amlogic_check", translate("Config Source"), nil)
b.description = translate("You can customize the storage site for plugin and kernel versions according to your needs.")
b.reset = false
b.submit = false
s = b:section(SimpleSection, "", "")

--1.Plugin
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

--2.Kernel
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
c.description = translate("Provide Plugin and Kernel online check and update service.")
c.pageaction = false

c:section(SimpleSection).template  = "amlogic/other_check"


return m, b, c
