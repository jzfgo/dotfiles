-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/configuring/core/autostart/
-- "hyprland.start" fires once per session (not on config reload), like exec-once.

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    -- hypridle ya lo arranca su servicio systemd de usuario (hypridle.service);
    -- lanzarlo aquí también creaba una segunda instancia con timers duplicados.
    -- hl.exec_cmd("hypridle")

    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")

    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("sh -lc 'sleep 1; /home/javi/.local/bin/awww-random /home/javi/Pictures/Wallpapers/EpicUltraWide 300 >> /tmp/awww-random.log 2>&1'")

    hl.exec_cmd("wl-paste --type text --watch cliphist store")  -- Stores only text data
    hl.exec_cmd("wl-paste --type image --watch cliphist store") -- Stores only image data
end)
