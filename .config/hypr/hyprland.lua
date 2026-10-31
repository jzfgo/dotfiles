-- Hyprland config (Lua, Hyprland >= 0.57). Each module lives in modules/.
-- See https://wiki.hypr.land/configuring/

require("modules.monitors")
require("modules.autostart")
require("modules.env")
require("modules.permissions")
require("modules.look_and_feel")
require("modules.input")
require("modules.keybindings")
require("modules.windows_and_workspaces")

-- Machine-local overrides (monitor layout, app paths). Untracked and optional:
-- create ~/.config/hypr/local.lua on machines that need it.
local ok, err = pcall(require, "local")
if not ok and not tostring(err):find("not found") then
    error(err)
end
