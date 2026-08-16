return {
  -- gitsigns keymaps (NvChad provides the plugin; we add on_attach for keymaps)
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      opts.on_attach = function(bufnr)
        local gs = require "gitsigns"
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- hunk navigation (falls back to diff-mode ]c/[c when in diff view)
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal { "]c", bang = true }
          else
            gs.nav_hunk "next"
          end
        end, "Next hunk")
        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal { "[c", bang = true }
          else
            gs.nav_hunk "prev"
          end
        end, "Prev hunk")

        -- hunk actions
        map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>gs", function()
          gs.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
        end, "Stage hunk (visual)")
        map("v", "<leader>gr", function()
          gs.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
        end, "Reset hunk (visual)")
        map("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")

        -- blame
        map("n", "<leader>gb", function()
          gs.blame_line { full = true }
        end, "Blame line (full)")
      end
    end,
  },

  {
    "3rd/image.nvim",
    build = "luarocks --local --lua-version=5.1 install magick",
    ft = { "markdown", "norg" },
    opts = require "configs.image",
  },

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
    -- extend NvChad's lazy-load triggers (Mason/MasonInstall/MasonUpdate)
    -- with the commands it leaves out
    cmd = { "MasonUninstall", "MasonUninstallAll", "MasonLog" },
    opts = require "configs.mason",
  },

  -- sync terminal background color
  { "typicode/bg.nvim", lazy = false },

  -- test new blink
  { import = "nvchad.blink.lazyspec" },

  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    opts = require "configs.nvim-treesitter",
  },

  {
    "davidmh/mdx.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    lazy = false,
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
    opts = require "configs.blink",
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
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input "Condition: ") end, desc = "Conditional breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "DAP continue / start" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>dT", function() require("dap").terminate() end, desc = "Terminate session" },
      { "<leader>dR", function() require("dap").run_last() end, desc = "Run last config" },
    },
  },

  -- DAP UI (opens automatically on session start)
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    keys = {
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
      { "<leader>de", function() require("dapui").eval() end, desc = "Eval expression", mode = { "n", "v" } },
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

  -- Python DAP adapter (uses Mason-managed debugpy)
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-python").setup(
        vim.fn.stdpath "data" .. "/mason/packages/debugpy/venv/bin/python"
      )
    end,
  },

  -- test runner: vitest (frontend) + pytest (backend) with inline results
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "marilari88/neotest-vitest",
      "nvim-neotest/neotest-python",
    },
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end, desc = "Run nearest test" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand "%") end, desc = "Run file tests" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle test summary" },
      { "<leader>to", function() require("neotest").output.open { enter = true } end, desc = "Test output" },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle output panel" },
      { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop test run" },
      { "<leader>td", function() require("neotest").run.run { strategy = "dap" } end, desc = "Debug nearest test" },
    },
    config = function()
      require("neotest").setup {
        adapters = {
          require "neotest-vitest",
          require("neotest-python") { dap = { justMyCode = false } },
        },
      }
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

  {
    "nvim-telescope/telescope-live-grep-args.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require "configs.telescope"
    end,
  },
}
