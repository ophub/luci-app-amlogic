-- SPDX-License-Identifier: GPL-2.0
-- PowerOff (Lua CBI model)
--
-- Purpose: render the shutdown page; the actual poweroff action is handled
-- inside the amlogic/other_poweroff HTM template.

local b

-- SimpleForm wrapper; content is delegated entirely to other_poweroff template.
b             = SimpleForm("poweroff", nil)
b.title       = translate("PowerOff")
b.description = translate("Shut down your router device.")
b.reset       = false
b.submit      = false

b:section(SimpleSection).template = "amlogic/other_poweroff"

return b
