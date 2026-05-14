-- SPDX-License-Identifier: GPL-2.0
-- Check Update (Lua CBI model)
--
-- Purpose: render the online update and rescue-kernel pages; all actual
-- logic runs inside the amlogic/other_check and other_rescue HTM templates.

local b, c

-- SimpleForm for online firmware/kernel/plugin update.
b             = SimpleForm("amlogic", nil)
b.title       = translate("Check Update")
b.description = translate("Provide OpenWrt Firmware, Kernel and Plugin online check, download and update service.")
b.reset       = false
b.submit      = false

b:section(SimpleSection).template = "amlogic/other_check"


-- SimpleForm for rescue kernel from alternate eMMC/NVMe/sdX partition.
c             = SimpleForm("rescue", nil)
c.title       = translate("Rescue Kernel")
c.description = translate("When a kernel update fails and causes the OpenWrt system to be unbootable, the kernel can be restored by mutual recovery from eMMC/NVMe/sdX.")
c.reset       = false
c.submit      = false

c:section(SimpleSection).template = "amlogic/other_rescue"

return b, c