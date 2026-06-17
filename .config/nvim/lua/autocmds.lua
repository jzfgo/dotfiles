require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd

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
      },
    }
  end,
})
