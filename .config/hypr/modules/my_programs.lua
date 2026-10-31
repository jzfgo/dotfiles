---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use. Other modules get them with
-- `local programs = require("modules.my_programs")`.
return {
    terminal    = "kitty",
    fileManager = "nautilus",
    menu        = "~/.config/rofi/launchers/type-2/launcher.sh || pkill rofi",
    browser     = "google-chrome-stable",
    colorPicker = "hyprpicker",
}
