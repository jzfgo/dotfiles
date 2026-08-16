local mason_pin = require "custom.mason-pin"
mason_pin.refresh()

local options = {
  -- Registry snapshot >= 7 days old (supply-chain delay); see custom/mason-pin.lua
  registries = { mason_pin.registry() },

  ensure_installed = {
    -- JS/TS
    "typescript-language-server",
    "svelte-language-server",
    "prettierd",
    -- Python
    "ty",
    "ruff",
    -- Markdown
    "marksman",
    -- Web
    "html-lsp",
    "css-lsp",
    -- Lua
    "lua-language-server",
    "stylua",
    -- YAML / XML / GraphQL / Terraform
    "yaml-language-server",
    "lemminx",
    "graphql-language-service-cli",
    "terraform-ls",
    -- Shell
    "shfmt",
    -- Debuggers
    "debugpy",
  },
}

return options
