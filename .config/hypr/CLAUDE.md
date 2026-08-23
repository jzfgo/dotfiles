# Hyprland (Linux)

`hyprland.conf` sources modular files from `modules/` (monitors, keybindings, autostart, look-and-feel, env, default apps).

Machine-specific overrides (monitor configs, local app paths) go in the untracked `~/.config/hypr/local.conf`. Likewise, `hyprpaper.conf` sources the untracked `~/.config/hypr/hyprpaper-local.conf` for the machine's `wallpaper { }` block. Both files must exist (create empty if needed) — Hyprland/hyprpaper error on a missing `source` target.
