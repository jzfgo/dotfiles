------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/configuring/core/monitors/
-- Machine-specific layout lives in ~/.config/hypr/local.lua (untracked);
-- named monitor rules there take precedence over this catch-all fallback.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})
