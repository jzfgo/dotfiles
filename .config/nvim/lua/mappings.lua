require "nvchad.mappings"

local map = vim.keymap.set
local lga = require "telescope-live-grep-args.shortcuts"

map("n", ";", ":", { desc = "CMD enter command mode" })

map("n", "<leader>li", function()
  vim.lsp.buf.code_action {
    apply = true,
    context = { only = { "source.addMissingImports.ts" }, diagnostics = {} },
  }
end, { desc = "LSP add missing imports" })

map("n", "<leader>X", ":%bd<cr>", { desc = "Close all buffers" })

-- live grep with args
map("n", "<leader>fg", "<cmd>Telescope live_grep_args<cr>", { desc = "Live grep (with rg args)" })
map("n", "<leader>fc", lga.grep_word_under_cursor, { desc = "Grep word under cursor" })
map("v", "<leader>fc", lga.grep_visual_selection, { desc = "Grep visual selection" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
