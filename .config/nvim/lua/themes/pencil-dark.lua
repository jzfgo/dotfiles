-- Credits to original theme https://github.com/preservim/vim-colors-pencil
-- Adapted for NvChad Base46 (dark variant, WCAG AA >= 4.5:1 muted text)

local M = {}

M.base_30 = {
  white = "#E5E6E6",
  darker_black = "#181818",
  black = "#212121", -- nvim bg
  black2 = "#262626",
  one_bg = "#303030",
  one_bg2 = "#3A3A3A",
  one_bg3 = "#424242",
  grey = "#545454",
  grey_fg = "#8A8A8A",
  grey_fg2 = "#949494",
  light_grey = "#949494", -- ~5.3:1 contrast on #212121
  red = "#E32791",
  baby_pink = "#FB007A",
  pink = "#FB007A",
  line = "#303030", -- for lines like vertsplit
  green = "#5FD7A7",
  vibrant_green = "#10A778",
  nord_blue = "#008EC4",
  blue = "#20BBFC",
  yellow = "#F3E430",
  sun = "#A89C14",
  purple = "#8775E8",
  dark_purple = "#6855DE",
  teal = "#20A5BA",
  orange = "#D75F5F",
  cyan = "#4FB8CC",
  statusline_bg = "#262626",
  lightbg = "#303030",
  pmenu_bg = "#20BBFC",
  folder_bg = "#20BBFC",
}

M.base_16 = {
  base00 = M.base_30.black,
  base01 = M.base_30.black2,
  base02 = M.base_30.one_bg3,
  base03 = M.base_30.grey_fg,
  base04 = M.base_30.light_grey,
  base05 = M.base_30.white,
  base06 = "#EDEDED",
  base07 = "#F1F1F1",
  base08 = M.base_30.red,
  base09 = M.base_30.cyan,
  base0A = M.base_30.purple,
  base0B = M.base_30.cyan,
  base0C = M.base_30.pink,
  base0D = M.base_30.blue,
  base0E = M.base_30.green,
  base0F = "#D9D9D9",
}

M.polish_hl = {
  syntax = {
    Include = { fg = M.base_30.red },
    PreProc = { fg = M.base_30.red },
    StorageClass = { fg = M.base_30.purple },
    Statement = { fg = M.base_30.green },
  },
  treesitter = {
    ["@keyword"] = { fg = M.base_30.green },
    ["@keyword.function"] = { fg = M.base_30.green },
    ["@keyword.return"] = { fg = M.base_30.green },
    ["@keyword.conditional"] = { fg = M.base_30.green },
    ["@keyword.repeat"] = { fg = M.base_30.green },
    ["@keyword.import"] = { fg = M.base_30.red },
    ["@string"] = { fg = M.base_30.cyan },
    ["@number"] = { fg = M.base_30.cyan },
    ["@boolean"] = { fg = M.base_30.cyan },
    ["@function"] = { fg = M.base_30.blue },
    ["@function.call"] = { fg = M.base_30.blue },
    ["@function.method"] = { fg = M.base_30.blue },
    ["@function.method.call"] = { fg = M.base_30.blue },
    ["@type"] = { fg = M.base_30.purple },
    ["@type.builtin"] = { fg = M.base_30.purple },
    ["@tag"] = { fg = M.base_30.blue },
    ["@tag.attribute"] = { fg = M.base_30.cyan },
    ["@punctuation.bracket"] = { fg = "#D9D9D9" },
    ["@punctuation.delimiter"] = { fg = "#D9D9D9" },
  },
}

M.type = "dark"

M = require("base46").override_theme(M, "pencil-dark")

return M
