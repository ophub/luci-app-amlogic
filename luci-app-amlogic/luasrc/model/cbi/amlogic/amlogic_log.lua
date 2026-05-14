-- SPDX-License-Identifier: GPL-2.0
-- Server Logs (Lua CBI model)
--
-- Purpose: render the log viewer page; content is displayed via the
-- amlogic/other_log HTM template which reads /tmp/amlogic/amlogic.log.

local b

-- SimpleForm for operation log display.
b = SimpleForm("amlogic_log", nil)
b.title = translate("Server Logs")
b.description = translate("Display the execution log of the current operation.")
b.reset = false
b.submit = false

s = b:section(SimpleSection, "", nil)

o = s:option(TextValue, "")
o.template = "amlogic/other_log"

return b
