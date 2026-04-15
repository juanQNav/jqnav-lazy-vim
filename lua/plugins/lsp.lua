return {
  -- Otter (embedded code LSP support)
  {
    "jmbuhr/otter.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {},
  },

  -- LSP core setup
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Mason ecosystem
      { "mason-org/mason.nvim", opts = {} },
      {
        "mason-org/mason-lspconfig.nvim",
        opts = {
          ensure_installed = {
            "pyright",
            "lua_ls",
            "bashls",
            "cssls",
            "html",
            "jsonls",
            "yamlls",
            "texlab",
            "clangd",
            "svelte",
            "ts_ls",
            "ruff",
            "r_language_server",
          },
          automatic_installation = true,
        },
        config = function(_, opts)
          require("mason-lspconfig").setup(opts)
        end,
      },
      {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = {
          ensure_installed = {
            "black",
            "isort",
            "ruff",
            "stylua",
            "shfmt",
            "tree-sitter-cli",
            "jupytext",
          },
        },
      },

      -- optional UI improvements
      { "j-hui/fidget.nvim", opts = {}, enabled = false },
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            { path = "luvit-meta/library", words = { "vim%.uv" } },
          },
        },
      },
      { "Bilal2453/luvit-meta", lazy = true },
    },

    config = function()
      local lspconfig = require("lspconfig")
      local util = require("lspconfig.util")

      -- Capabilities (completion integration)
      local capabilities = require("blink.cmp").get_lsp_capabilities({}, true)

      local lsp_flags = {
        debounce_text_changes = 150,
      }

      -- Auto root detection helper
      local function root_pattern(...)
        return util.root_pattern(...)
      end

      -- Common LSP attach behavior
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local function map(keys, func, desc)
            vim.keymap.set("n", keys, func, {
              buffer = event.buf,
              desc = "LSP: " .. desc,
            })
          end

          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gD", vim.lsp.buf.type_definition, "Go to type definition")
          map("<leader>dq", vim.diagnostic.setqflist, "Diagnostics quickfix")
        end,
      })

      -- =====================
      -- LSP CONFIGURATIONS
      -- =====================

      lspconfig.pyright.setup({
        capabilities = capabilities,
        flags = lsp_flags,
        root_dir = root_pattern("pyproject.toml", "setup.py", "requirements.txt", "Pipfile", ".git"),
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoImportCompletions = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        flags = lsp_flags,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { disable = { "trailing-space" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })

      lspconfig.bashls.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      lspconfig.cssls.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      lspconfig.html.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      lspconfig.jsonls.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      lspconfig.yamlls.setup({
        capabilities = capabilities,
        flags = lsp_flags,
        settings = {
          yaml = {
            schemaStore = { enable = true },
          },
        },
      })

      lspconfig.texlab.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      lspconfig.clangd.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      lspconfig.svelte.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      lspconfig.rust_analyzer.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      lspconfig.r_language_server.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      -- Ruff (linting)
      lspconfig.ruff.setup({
        capabilities = capabilities,
        flags = lsp_flags,
        root_dir = root_pattern("pyproject.toml", "ruff.toml", ".git"),
      })
    end,
  },
}
