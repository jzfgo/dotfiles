require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd

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

