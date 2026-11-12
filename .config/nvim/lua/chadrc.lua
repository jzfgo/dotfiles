-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "pencil-dark",
  theme_toggle = { "pencil-dark", "pencil-light" },
  transparency = true,

  -- `light_grey` drives Comment plus every other muted-text group (bufferline
  -- inactive tabs, folded text, NvDash buttons, git/lsp/mason muted text...).
  -- Override per theme so comments and muted text meet WCAG AA (>= 4.5:1):
  -- - catppuccin (Mocha dark): Overlay2 #9399b2 (~5.8:1 on #1E1D2D)
  -- - catppuccin_latte (Latte light, note underscore in base46): Subtext1 #5c5f77 (~5.5:1 on #EFF1F5)
  -- - chadracula-evondev: base0F #7e7eb5 (~4.8:1 on #141423)
  changed_themes = {
    catppuccin = {
      base_30 = {
        light_grey = "#9399b2",
      },
    },
    catppuccin_latte = {
      base_30 = {
        grey = "#8c8fa1",
        grey_fg = "#7c7f93",
        grey_fg2 = "#6c6f85",
        light_grey = "#5c5f77",
      },
      base_16 = {
        base03 = "#8c8fa1",
        base04 = "#7c7f93",
      },
    },
    ["chadracula-evondev"] = {
      base_30 = {
        light_grey = "#7e7eb5",
      },
    },
  },

  -- Real code comments are highlighted via treesitter's `@comment`, which
  -- (unlike the legacy `Comment` group above) reads `grey_fg` instead of
  -- `light_grey` — that's why changing the palette alone didn't touch them.
  -- Point `@comment` at the same already-fixed `light_grey` so both paths
  -- land on the same color.
  hl_override = {
    ["@comment"] = { fg = "light_grey" },
    -- Base46's minimal statusline sets `bg = colors.black` on left pill caps
    -- (``) while right caps (``) have `bg = "none"`. With transparency
    -- enabled, that leaves an opaque corner box behind every left cap.
    St_NormalModeSep = { bg = "NONE" },
    St_VisualModeSep = { bg = "NONE" },
    St_InsertModeSep = { bg = "NONE" },
    St_TerminalModeSep = { bg = "NONE" },
    St_NTerminalModeSep = { bg = "NONE" },
    St_ReplaceModeSep = { bg = "NONE" },
    St_ConfirmModeSep = { bg = "NONE" },
    St_CommandModeSep = { bg = "NONE" },
    St_SelectModeSep = { bg = "NONE" },
    St_file_sep = { bg = "NONE" },
    St_cwd_sep = { bg = "NONE" },
    St_Pos_sep = { bg = "NONE" },
    St_lsp_sep = { bg = "NONE" },
  },
}

M.nvdash = { load_on_startup = true }
M.ui = {
  statusline = {
    theme = "minimal",
    separator_style = "round",

    -- The minimal theme calls utils.generate("default", ...), so this is the
    -- `default` order with `words` spliced in before cwd, not minimal's own.
    order = { "mode", "file", "git", "%=", "lsp_msg", "%=", "diagnostics", "lsp", "words", "cwd", "cursor" },

    modules = {
      -- required lazily: chadrc is read before the runtime path is fully set up
      words = function()
        return require("custom.wordcount").statusline()
      end,
    },
  },

  tabufline = {
    lazyload = true,
  },
}

return M
