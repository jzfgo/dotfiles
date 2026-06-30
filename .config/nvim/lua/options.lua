require "nvchad.options"

local opt = vim.opt
local o = vim.o
local g = vim.g

o.cursorlineopt = "both"

o.scrolloff = 10
o.number = true
o.relativenumber = true

-- Enable clipboard through SSH
g.clipboard = {
  name = "osc52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy "+",
    ["*"] = require("vim.ui.clipboard.osc52").copy "*",
  },
  paste = {
    ["+"] = require("vim.ui.clipboard.osc52").paste "+",
    ["*"] = require("vim.ui.clipboard.osc52").paste "*",
  },
}

opt.clipboard = "unnamedplus"
