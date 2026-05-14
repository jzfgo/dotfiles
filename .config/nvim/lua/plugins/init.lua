return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- JS/TS
        "typescript-language-server",
        "prettierd",
        -- Python
        "basedpyright",
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
      },
    },
  },

  -- sync terminal background color
  { "typicode/bg.nvim", lazy = false },

  -- test new blink
  { import = "nvchad.blink.lazyspec" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "python",
        "markdown",
        "markdown_inline",
        "yaml",
        "dockerfile",
        "graphql",
        "bash",
        "terraform",
        "proto",
      },
    },
  },

  {
    "davidmh/mdx.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    lazy = false,
  },

  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup {
        suggestion = { enabled = false },
        panel = { enabled = false },
      }
    end,
  },

  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    cmd = { "CopilotChat", "CopilotChatOpen", "CopilotChatToggle" },
    keys = {
      { "<leader>cc", "<cmd>CopilotChatToggle<cr>", desc = "Toggle CopilotChat" },
      { "<leader>ce", "<cmd>CopilotChatExplain<cr>", mode = { "n", "v" }, desc = "Explain" },
      { "<leader>cf", "<cmd>CopilotChatFix<cr>", mode = { "n", "v" }, desc = "Fix" },
      { "<leader>ct", "<cmd>CopilotChatTests<cr>", mode = { "n", "v" }, desc = "Generate tests" },
      { "<leader>cr", "<cmd>CopilotChatReview<cr>", mode = { "n", "v" }, desc = "Review" },
    },
    opts = {
      model = "gpt-4.1",
      temperature = 0.1,
      trusted_tools = nil,
      window = {
        layout = "vertical",
        width = 0.5,
      },
      auto_insert_mode = true,
    },
  },

  -- surround: ys/cs/ds to add/change/delete surrounding chars
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  -- diagnostics, references, quickfix in a unified panel
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
      { "<leader>xw", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle<cr>", desc = "Document symbols" },
    },
  },

  -- highlight and search TODO/FIXME/NOTE/HACK comments
  {
    "folke/todo-comments.nvim",
    event = "User FilePost",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "<leader>xt", "<cmd>TodoTelescope<cr>", desc = "Todo comments" },
    },
  },

  {
    "saghen/blink.cmp",
    dependencies = { "fang2hou/blink-copilot" },
    opts = {
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "copilot" },
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            score_offset = 100,
            async = true,
          },
        },
      },
    },
  },

  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    build = "make install_jsregexp",
    config = function()
      require "nvchad.configs.luasnip"
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  -- auto close/rename HTML and JSX/TSX tags via treesitter
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {},
  },

  -- camelCase / snake_case / UPPER_CASE / kebab-case conversions (cr prefix)
  {
    "tpope/vim-abolish",
    event = "VeryLazy",
  },

  -- full-screen git diff and per-file history (complements gitsigns)
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff view" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
    },
  },

  -- DAP core
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle breakpoint",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "DAP continue",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Step into",
      },
      {
        "<leader>do",
        function()
          require("dap").step_over()
        end,
        desc = "Step over",
      },
    },
  },

  -- DAP UI (opens automatically on session start)
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    keys = {
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Toggle DAP UI",
      },
    },
    config = function()
      local dap, dapui = require "dap", require "dapui"
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  -- Python DAP adapter (uses debugpy)
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-python").setup "python3"
    end,
  },

  -- show latest npm versions inline in package.json
  {
    "vuki656/package-info.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    ft = "json",
    opts = {},
    keys = {
      {
        "<leader>ns",
        function()
          require("package-info").show()
        end,
        desc = "Show package versions",
      },
      {
        "<leader>nu",
        function()
          require("package-info").update()
        end,
        desc = "Update package",
      },
    },
  },

  -- render markdown inline (headings, tables, code blocks, checkboxes)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown", "mdx" },
    opts = {},
  },
}
