require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd

-- Base46's compiled `defaults` cache sets `vim.o.bg` during init.lua, which
-- marks 'background' as user-set (`was_set = true`) and causes Neovim's
-- built-in `nvim.tty` VimEnter autocmd to delete its `TermResponse` OSC 11
-- listener. Remove that `VimEnter` cleanup autocmd so Neovim keeps updating
-- `vim.o.background` when the terminal switches between light and dark themes.
local ok_tty, tty_autocmds = pcall(vim.api.nvim_get_autocmds, {
  group = "nvim.tty",
  event = "VimEnter",
})
if ok_tty then
  for _, au in ipairs(tty_autocmds) do
    if type(au.callback) == "function" and debug.getupvalue(au.callback, 1) == "id" then
      pcall(vim.api.nvim_del_autocmd, au.id)
    end
  end
end

-- Sync NvChad's Base46 theme with Neovim's `background` option (`dark` ->
-- pencil-dark, `light` -> pencil-light), both on startup and live when
-- the OS/terminal appearance changes.
local current_compiled_bg = vim.g.base46_cached_bg
require("nvconfig").base46.theme = current_compiled_bg == "light" and "pencil-light" or "pencil-dark"

local function sync_theme_with_background()
  local bg = vim.o.background
  local target = bg == "light" and "pencil-light" or "pencil-dark"
  local nvconfig = require "nvconfig"

  if nvconfig.base46.theme ~= target or current_compiled_bg ~= bg then
    current_compiled_bg = bg
    nvconfig.base46.theme = target
    require("base46").load_all_highlights()
  end
end

autocmd("OptionSet", {
  pattern = "background",
  callback = sync_theme_with_background,
})

autocmd("UIEnter", {
  once = true,
  callback = sync_theme_with_background,
})

-- Re-apply NvimTree transparency after each colorscheme load, since themes reset all highlights
autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    local highlights = {
      "NvimTreeNormal",
      "NvimTreeNormalNC",
      "NvimTreeWinSeparator",
    }
    for _, hl in ipairs(highlights) do
      vim.api.nvim_set_hl(0, hl, { bg = "none", ctermbg = "none" })
    end
  end,
})

-- Organize imports on save for js/ts files (sort + remove unused, never adds new ones)
autocmd("BufWritePre", {
  pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.svelte" },
  callback = function()
    local clients = vim.lsp.get_clients { bufnr = 0, name = "ts_ls" }
    if #clients == 0 then
      return
    end
    clients[1]:request_sync("workspace/executeCommand", {
      command = "_typescript.organizeImports",
      arguments = { vim.api.nvim_buf_get_name(0) },
    }, 3000, 0)
  end,
})

-- Restore cursor position on file open
autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local line = vim.fn.line "'\""
    if
      line > 1
      and line <= vim.fn.line "$"
      and vim.bo.filetype ~= "commit"
      and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1
    then
      vim.cmd 'normal! g`"'
    end
  end,
})

-- Show Nvdash when all buffers are closed
autocmd("BufDelete", {
  callback = function()
    local bufs = vim.t.bufs
    if #bufs == 1 and vim.api.nvim_buf_get_name(bufs[1]) == "" then
      vim.cmd "Nvdash"
    end
  end,
})

-- Custom surrounds by filetype, e.g. for markdown files
autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    require("nvim-surround").buffer_setup {
      aliases = {
        -- disable default b -> ")" alias so our bold surround below works
        ["b"] = "b",
      },
      surrounds = {
        ["l"] = {
          add = function()
            local clipboard = vim.fn.getreg("+"):gsub("\n", "")
            return {
              { "[" },
              { "](" .. clipboard .. ")" },
            }
          end,
          find = "%b[]%b()",
          delete = "^(%[)().-(%]%b())()$",
          change = {
            target = "^()()%b[]%((.-)()%)$",
            replacement = function()
              local clipboard = vim.fn.getreg("+"):gsub("\n", "")
              return {
                { "" },
                { clipboard },
              }
            end,
          },
        },
        ["b"] = {
          add = { "**", "**" },
          find = "%*%*.-%*%*",
          delete = "^(%*%*)().-(%*%*)()$",
        },
      },
    }
  end,
})
