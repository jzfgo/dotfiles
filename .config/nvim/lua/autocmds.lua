require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd

autocmd("BufWritePre", {
  pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
  callback = function()
    local clients = vim.lsp.get_clients({ bufnr = 0, name = "ts_ls" })
    for _, client in ipairs(clients) do
      client:request_sync("workspace/executeCommand", {
        command = "_typescript.organizeImports",
        arguments = { vim.api.nvim_buf_get_name(0) },
      }, 3000, 0)
    end
  end,
})

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
