require "nvchad.options"

local o = vim.o
o.cursorlineopt ='both'

o.scrolloff = 10
o.number = true
o.relativenumber = true

-- Enable clipboard through SSH
vim.g.clipboard = {
  name = 'osc52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}


vim.opt.clipboard = "unnamedplus"
