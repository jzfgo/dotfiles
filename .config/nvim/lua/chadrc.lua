-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "chadracula-evondev",
  theme_toggle = { "chadracula-evondev", "chadracula-evondev" },
  transparency = true,

  -- `light_grey` drives Comment plus every other muted-text group (bufferline
  -- inactive tabs, folded text, NvDash buttons, git/lsp/mason muted text...).
  -- The theme's own #6060a4 only hits ~3.2:1 contrast on the dark bg (fails
  -- WCAG AA's 4.5:1 for body text). Reuse base0F (#7e7eb5), already in this
  -- theme for delimiters/punctuation, which gets ~4.8:1.
  changed_themes = {
    ["chadracula-evondev"] = {
      base_30 = {
        light_grey = "#7e7eb5",
      },
    },
  },

  -- Real code comments are highlighted via treesitter's `@comment`, which
  -- (unlike the legacy `Comment` group above) reads `grey_fg` (#4b4b83,
  -- ~2.3:1 contrast) instead of `light_grey` — that's why changing the
  -- palette alone didn't touch them. Point `@comment` at the same
  -- already-fixed `light_grey` so both paths land on the same color.
  hl_override = {
    ["@comment"] = { fg = "light_grey" },
  },
}

M.nvdash = { load_on_startup = true }
M.ui = {
  statusline = {
    theme = "minimal",
    separator_style = "round",
  },

  tabufline = {
    lazyload = true,
  },
}

return M
