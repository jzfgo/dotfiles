---------------
---- INPUT ----
---------------

-- https://wiki.hypr.land/configuring/core/config-options/#input
hl.config({
    input = {
        kb_layout = "es",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll       = true,
            tap_to_click         = true,
            clickfinger_behavior = true,
            tap_and_drag         = true,
            drag_lock            = true,
        },
    },
})

-- See https://wiki.hypr.land/configuring/core/gestures/
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-- Example per-device config
-- See https://wiki.hypr.land/configuring/core/devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})
