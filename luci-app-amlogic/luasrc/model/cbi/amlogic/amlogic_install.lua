-- SPDX-License-Identifier: GPL-2.0
-- Install OpenWrt (Lua CBI model)
--
-- Purpose: render the install-to-eMMC page; device selection and install
-- logic live inside the amlogic/other_install HTM template.

local b

-- SimpleForm wrapper; content is delegated entirely to other_install template.
b             = SimpleForm("amlogic_install", nil)
b.title       = translate("Install OpenWrt")
b.description = translate("Install OpenWrt to EMMC, Please select the device model, Or enter the dtb file name.")
b.reset       = false
b.submit      = false

b:section(SimpleSection).template = "amlogic/other_install"

return b
