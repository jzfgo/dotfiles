--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/configuring/core/rules/

hl.window_rule({
    -- Check if window is xwayland
    name  = "xwayland-border",
    match = { xwayland = true },

    border_color = "rgb(ff5555)",
})

hl.window_rule({
    name  = "rofi-translucent",
    match = { class = "^(Rofi)$" },

    opacity = "0.85 0.85",
    no_blur = false,
})

hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    -- Keep the screen awake while anything is fullscreen (games, Steam Big
    -- Picture) — hypridle only sees keyboard/mouse, not gamepad input.
    name  = "fullscreen-inhibits-idle",
    match = { fullscreen = true },

    idle_inhibit = "fullscreen",
})

hl.window_rule({
    -- Steam games in borderless/windowed mode never enter the fullscreen
    -- state, so the rule above misses them — inhibit while any Steam game
    -- window has focus, regardless of display mode.
    name  = "steam-games-inhibit-idle",
    match = { class = "^(steam_app_\\d+)$" },

    idle_inhibit = "focus",
})

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})
