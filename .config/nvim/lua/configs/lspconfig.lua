require("nvchad.configs.lspconfig").defaults()

vim.lsp.config("marksman", {
  cmd = { "marksman", "server" },
  filetypes = { "markdown", "markdown.mdx" },
  root_markers = { ".marksman.toml", ".git" },
})

vim.lsp.config("ty", {
  settings = {
    ty = {
      -- "openFilesOnly" (default) or "workspace"
      diagnosticMode = "openFilesOnly",
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
  "ty",
  "cssls",
  "html",
  "lemminx",
  "marksman",
  "svelte",
  "terraformls",
  "ts_ls",
  "yamlls",
}

vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
