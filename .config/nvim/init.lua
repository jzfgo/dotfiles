vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- Preserve the terminal's initial `background` detection before Base46's
-- cached `defaults` file overwrites `vim.o.bg` with the last compiled theme's
-- background.
local initial_bg = vim.o.background

-- load theme
if vim.uv.fs_stat(vim.g.base46_cache .. "defaults") then
  dofile(vim.g.base46_cache .. "defaults")
  dofile(vim.g.base46_cache .. "statusline")
  vim.g.base46_cached_bg = vim.o.background
end

if vim.o.background ~= initial_bg then
  vim.o.background = initial_bg
end

require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)
