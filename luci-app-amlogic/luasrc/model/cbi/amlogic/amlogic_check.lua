local fs = require "luci.fs"
local http = require "luci.http"
local DISP = require "luci.dispatcher"
local m, b, c

--Set Default value
default_firmware_repo="ophub/amlogic-s9xxx-openwrt"
local amlogic_firmware_repo = luci.sys.exec("uci get amlogic.config.amlogic_firmware_repo 2>/dev/null") or default_firmware_repo

default_firmware_tag="s9xxx_lede"
local amlogic_firmware_tag = luci.sys.exec("uci get amlogic.config.amlogic_firmware_tag 2>/dev/null") or default_firmware_tag

default_firmware_suffix=".img.gz"
local amlogic_firmware_suffix = luci.sys.exec("uci get amlogic.config.amlogic_firmware_suffix 2>/dev/null") or default_firmware_suffix

default_kernel_path="amlogic-s9xxx/amlogic-kernel"
local amlogic_kernel_path = luci.sys.exec("uci get amlogic.config.amlogic_kernel_path 2>/dev/null") or default_kernel_path

--SimpleForm for nil
m = SimpleForm("", "", nil)
m.reset = false
m.submit = false

--SimpleForm for Config Source
b = SimpleForm("amlogic_check", translate("Config Source"), nil)
b.description = translate("You can customize the check url for OpenWrt kernel and plugin according to your needs.") .. '<br><br>' ..
                translate("OpenWrt Firmware DownLoad URL:") .. '<br>' ..
                'https://github.com/<span style="color: green"><b>ophub/amlogic-s9xxx-openwrt</b></span>/releases/download/openwrt_<span style="color: green"><b>s9xxx_lede</b></span>_2021.06/openwrt_<span style="color: blue">s905d</span>_v<span style="color: blue">5.12</span>.9_2021.06<span style="color: green"><b>.img.gz</b></span>' .. '<br>' ..
                translate("The amlogic SoC (E.g: s905d) and mainline version of the kernel (E.g: 5.12) will automatically match the current openwrt firmware.") .. '<br><br>' ..
                translate("OpenWrt Kernel DownLoad URL:") .. '<br>' ..
                'https://github.com/<span style="color: green"><b>ophub/amlogic-s9xxx-openwrt</b></span>/tree/main/<span style="color: green"><b>amlogic-s9xxx/amlogic-kernel</b></span>'
b.reset = false
b.submit = false
s = b:section(SimpleSection, "", "")

--1.Set OpenWrt Firmware Repository
o = s:option(Value, "firmware_repo", translate("OpenWrt Firmware Repository:"))
o.rmempty = true
o.default = amlogic_firmware_repo
o.write = function(self, key, value)
	if value == "" then
        --self.description = translate("Invalid value.")
        amlogic_firmware_repo = default_firmware_repo
	else
        --self.description = translate("OpenWrt Firmware Repository:") .. value
        amlogic_firmware_repo = value
	end
end

--2.Set Releases Tag key words
o = s:option(Value, "firmware_tag", translate("Releases Tag Keywords:"))
o.rmempty = true
o.default = amlogic_firmware_tag
o.write = function(self, key, value)
	if value == "" then
        --self.description = translate("Invalid value.")
        amlogic_firmware_tag = default_firmware_tag
	else
        --self.description = translate("Releases Tag Keywords:") .. value
        amlogic_firmware_tag = value
	end
end

--3.Set OpenWrt Firmware Suffix
o = s:option(Value, "firmware_suffix", translate("OpenWrt Firmware Suffix:"))
o.rmempty = true
o.default = amlogic_firmware_suffix
o.write = function(self, key, value)
	if value == "" then
        --self.description = translate("Invalid value.")
        amlogic_firmware_suffix = default_firmware_suffix
	else
        --self.description = translate("OpenWrt Firmware Suffix:") .. value
        amlogic_firmware_suffix = value
	end
end

--4.Set OpenWrt Kernel Path
o = s:option(Value, "kernel_repo", translate("OpenWrt Kernel Path:"))
o.rmempty = true
o.default = amlogic_kernel_path
o.write = function(self, key, value)
	if value == "" then
        --self.description = translate("Invalid value.")
        amlogic_kernel_path = default_kernel_path
	else
        --self.description = translate("OpenWrt Kernel Path:") .. value
        amlogic_kernel_path = value
	end
end

--5.Save button
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
	luci.sys.exec("uci set amlogic.config.amlogic_firmware_repo=" .. amlogic_firmware_repo .. " 2>/dev/null")
	luci.sys.exec("uci set amlogic.config.amlogic_firmware_tag=" .. amlogic_firmware_tag .. " 2>/dev/null")
	luci.sys.exec("uci set amlogic.config.amlogic_firmware_suffix=" .. amlogic_firmware_suffix .. " 2>/dev/null")
	luci.sys.exec("uci set amlogic.config.amlogic_kernel_path=" .. amlogic_kernel_path .. " 2>/dev/null")
	luci.sys.exec("uci commit amlogic 2>/dev/null")
	http.redirect(DISP.build_url("admin", "system", "amlogic", "check"))
	--self.description = "amlogic_check_url: " .. amlogic_check_url
end

--SimpleForm for Check
c = Map("amlogic")
c.title = translate("Check Update")
c.description = translate("Provide OpenWrt Firmware, Kernel and Plugin online check, download and update service.")
c.pageaction = false
c:section(SimpleSection).template  = "amlogic/other_check"

return m, b, c
