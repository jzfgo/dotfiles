-- Credits to original theme https://github.com/preservim/vim-colors-pencil
-- Adapted for NvChad Base46 (light variant, WCAG AA >= 4.5:1 muted text)

local M = {}

M.base_30 = {
  white = "#424242",
  darker_black = "#E5E6E6",
  black = "#F1F1F1", -- nvim bg
  black2 = "#E5E6E6",
  one_bg = "#D9D9D9",
  one_bg2 = "#CECECE",
  one_bg3 = "#C2C2C2",
  grey = "#8A8A8A",
  grey_fg = "#6E6E6E",
  grey_fg2 = "#636363",
  light_grey = "#5F5F5F", -- ~5.65:1 contrast on #F1F1F1
  red = "#C30771",
  baby_pink = "#E32791",
  pink = "#C30771",
  line = "#D9D9D9", -- for lines like vertsplit
  green = "#0B7A57",
  vibrant_green = "#10A778",
  nord_blue = "#005F87",
  blue = "#006C96",
  yellow = "#7D730C",
  sun = "#A89C14",
  purple = "#523C79",
  dark_purple = "#523C79",
  teal = "#147888",
  orange = "#B84444",
  cyan = "#147888",
  statusline_bg = "#E5E6E6",
  lightbg = "#D9D9D9",
  pmenu_bg = "#006C96",
  folder_bg = "#006C96",
}

M.base_16 = {
  base00 = M.base_30.black,
  base01 = M.base_30.black2,
  base02 = "#B6D6FD",
  base03 = M.base_30.grey_fg,
  base04 = M.base_30.light_grey,
  base05 = M.base_30.white,
  base06 = "#303030",
  base07 = "#212121",
  base08 = M.base_30.red,
  base09 = M.base_30.cyan,
  base0A = M.base_30.purple,
  base0B = M.base_30.cyan,
  base0C = M.base_30.pink,
  base0D = M.base_30.blue,
  base0E = M.base_30.green,
  base0F = "#545454",
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
    ["@punctuation.bracket"] = { fg = "#545454" },
    ["@punctuation.delimiter"] = { fg = "#545454" },
  },
  telescope = {
    TelescopeMatching = { fg = M.base_30.blue, bg = M.base_30.one_bg },
  },
}

M.type = "light"

M = require("base46").override_theme(M, "pencil-light")

return M
