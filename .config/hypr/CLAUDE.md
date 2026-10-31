# Hyprland (Linux)

Config is Lua (Hyprland >= 0.57 dropped hyprlang `.conf`). `hyprland.lua` `require`s the modules in `modules/` (monitors, autostart, env, permissions, look_and_feel, input, keybindings, windows_and_workspaces). Program names shared between modules live in `modules/my_programs.lua`, which returns a table.

Machine-specific overrides (monitor configs, local binds/autostart) go in the untracked, optional `~/.config/hypr/local.lua` (loaded last via `pcall(require, "local")`; a missing file is fine). Validate changes with `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`.

`hyprctl dispatch` now takes Lua dispatchers, e.g. `hyprctl dispatch 'hl.dsp.dpms({action = "off"})'` — the old `hyprctl dispatch dpms off` form errors out.

`hyprpaper.conf` sources the untracked `~/.config/hypr/hyprpaper-local.conf` for the machine's `wallpaper { }` block; it must exist (hyprpaper errors on a missing `source` target). hyprpaper/hypridle/hyprlock still use hyprlang `.conf`.
