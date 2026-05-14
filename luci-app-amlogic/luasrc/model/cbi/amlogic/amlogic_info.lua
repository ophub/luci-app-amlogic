-- SPDX-License-Identifier: GPL-2.0
-- Amlogic Service Info (Lua CBI model)
--
-- Purpose: render the plugin home page; all status display logic lives
-- inside the amlogic/other_info HTM template.

local b

-- SimpleForm wrapper; content is delegated entirely to other_info template.
b             = SimpleForm("amlogic", nil)
b.title       = translate("Amlogic Service")
b.description = translate("Supports management of Amlogic s9xxx, Allwinner (V-Plus Cloud), and Rockchip (BeikeYun, Chainedbox L1 Pro) boxes.")
b.reset       = false
b.submit      = false

b:section(SimpleSection).template = "amlogic/other_info"

return b
