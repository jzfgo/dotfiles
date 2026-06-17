require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })

map("n", "<leader>li", function()
  vim.lsp.buf.code_action {
    apply = true,
    context = { only = { "source.addMissingImports.ts" }, diagnostics = {} },
  }
end, { desc = "LSP add missing imports" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
