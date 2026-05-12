local options = {
  formatters_by_ft = {
    lua = { "stylua" },

    css = { "prettierd", "prettier", stop_after_first = true },
    html = { "prettierd", "prettier", stop_after_first = true },

    python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },

    json = { "prettierd", "prettier", stop_after_first = true },
    markdown = { "prettierd", "prettier", stop_after_first = true },
    mdx = { "prettierd", "prettier", stop_after_first = true },

    sh = { "shfmt" },
    bash = { "shfmt" },
    zsh = { "shfmt" },

    javascript = { "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { "prettierd", "prettier", stop_after_first = true },
    typescript = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
