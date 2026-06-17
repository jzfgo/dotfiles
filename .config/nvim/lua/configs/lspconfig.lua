require("nvchad.configs.lspconfig").defaults()

vim.lsp.config("marksman", {
  cmd = { "marksman", "server" },
  filetypes = { "markdown", "markdown.mdx" },
  root_markers = { ".marksman.toml", ".git" },
})

vim.lsp.config("basedpyright", {
  settings = {
    basedpyright = {
      disableOrganizeImports = true,
      -- analysis = { ignore = { '*' } }, -- ruff does linting
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
        typeCheckingMode = "basic",
        diagnosticSeverityOverrides = {
          reportOptionalMemberAccess = false, -- "warning"
        },
      },
    },
  },
})

vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      schemaStore = { enable = true },
      validate = true,
    },
  },
})

local servers = {
  "html", "cssls", "ts_ls", "svelte",
  "marksman", "basedpyright",
  "yamlls", "lemminx", "graphql", "terraformls",
}

vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
