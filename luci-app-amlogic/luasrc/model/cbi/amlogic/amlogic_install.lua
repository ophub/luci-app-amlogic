local fs = require "luci.fs"
local http = require "luci.http"
local DISP = require "luci.dispatcher"
local m, b, mlog

--SimpleForm for Install OpenWrt to EMMC
m = SimpleForm("", "", nil)
m.reset = false
m.submit = false


--SimpleForm for Install OpenWrt to Amlogic EMMC
b = SimpleForm("amlogic_install", translate("Install OpenWrt"), nil)
b.description = translate("Install OpenWrt to Amlogic EMMC, Please Select the Amlogic SoC, Or enter the dtb file name.")
b.reset = false
b.submit = false
s = b:section(SimpleSection, "", "")

--1.Select menu
o = s:option(ListValue, "amlogic_soc", translate("Select the Amlogic SoC:"))
o.default = "0"
o.datatype = "uinteger"
o:value("0", translate("Select List"))
o:value("1", translate("X96-Max+ (4G DDR) 2124Mtz"))
o:value("2", translate("X96-Max+ (4G DDR) 2208Mtz"))
o:value("3", translate("HK1-Box (4G DDR) 2124Mtz"))
o:value("4", translate("HK1-Box (4G DDR) 2184Mtz"))
o:value("5", translate("H96-Max-X3 (4G DDR) 2124Mtz"))
o:value("6", translate("H96-Max-X3 (4G DDR) 2208Mtz"))
o:value("7", translate("Ugoos-X3 (Cube/Pro/Plus) 2124Mtz"))
o:value("8", translate("Ugoos-X3 (Cube/Pro/Plus) 2208Mtz"))
o:value("9", translate("X96-Max-4G"))
o:value("10", translate("X96-Max-2G"))
o:value("11", translate("Belink-GT-King"))
o:value("12", translate("Belink-GT-King-Pro"))
o:value("13", translate("UGOOS-AM6-Plus"))
o:value("14", translate("Octopus-Planet"))
o:value("15", translate("PhicommN1"))
o:value("16", translate("HG680P & B860H"))
o:value("99", translate("Enter the dtb file name"))
o.write = function(self, key, value)
	--self.description = value
	emmc_soc = value
end

--2.dtb fill in the text box
o = s:option(Value, "amlogic_dtb", translate("Or enter the dtb file name:"))
o.rmempty = true
o.default = "no"
o.write = function(self, key, value)
	if (string.lower(string.sub(value, -4, -1)) == ".dtb") then
        self.description = translate("Use custom dtb file:") .. value
        emmc_dtb = value
	else
        self.description = translate("Invalid dtb file.")
        emmc_dtb = "no"
	end
end
o:depends("amlogic_soc", "99")

--3.Install button
o = s:option(Button, "", translate("Install OpenWrt:"))
o.template = "amlogic/other_button"
o.render = function(self, section, scope)
	self.section = true
	scope.display = ""
	self.inputtitle = translate("Install")
	self.inputstyle = "apply"
	Button.render(self, section, scope)
end
o.write = function(self, section, scope)
	if not emmc_dtb then
	    emmc_dtb = "no"
	end
	local x = luci.sys.exec("chmod +x /usr/bin/openwrt-install 2>/dev/null")
	local r = luci.sys.exec("/usr/bin/openwrt-install TEST-UBOOT YES " .. emmc_soc .. " " .. emmc_dtb .. " > /tmp/amlogic.log && sync 2>/dev/null")
	--self.description = "SOC: " .. emmc_soc .. " dtb: " .. emmc_dtb
end

--SimpleForm for Server Logs
mlog = SimpleForm("amlogic_log", translate("Server Logs"), nil)
mlog.reset = false
mlog.submit = false
slog = mlog:section(SimpleSection, "", translate("Display the execution log of the current operation."))
olog = slog:option(TextValue, "")
olog.template = "amlogic/other_log"

return m, b, mlog
