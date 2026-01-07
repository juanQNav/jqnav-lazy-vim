return {
  { -- for lsp features in code cells / embedded code
    "jmbuhr/otter.nvim",
    dev = false,
    dependencies = {
      {
        "neovim/nvim-lspconfig",
        "nvim-treesitter/nvim-treesitter",
      },
    },
    opts = {},
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim" },
      { "mason-org/mason-lspconfig.nvim" },
      { "WhoIsSethDaniel/mason-tool-installer.nvim" },
      { -- nice loading notifications
        -- PERF: but can slow down startup
        "j-hui/fidget.nvim",
        enabled = false,
        opts = {},
      },
      {
        {
          "folke/lazydev.nvim",
          ft = "lua", -- only load on lua files
          opts = {
            library = {
              -- See the configuration section for more details
              -- Load luvit types when the `vim.uv` word is found
              { path = "luvit-meta/library", words = { "vim%.uv" } },
            },
          },
        },
        { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
      },
      { "folke/neoconf.nvim", opts = {}, enabled = false },
    },
    config = function()
      local lspconfig = require("lspconfig")
      local util = require("lspconfig.util")

      -- Function to detect Python virtual environment
      local function get_python_path(workspace)
        -- Search for common virtual environment paths
        local venv_paths = {
          workspace .. "/venv/bin/python",
          workspace .. "/.venv/bin/python",
          workspace .. "/env/bin/python",
          workspace .. "/.env/bin/python",
          workspace .. "/virtualenv/bin/python",
        }

        -- Check if any virtual environment exists
        for _, path in ipairs(venv_paths) do
          local f = io.open(path, "r")
          if f ~= nil then
            f:close()
            return path
          end
        end

        -- If no venv found, use system python
        return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
      end

      require("mason").setup({
        ensure_installed = {
          "lua-language-server",
          "bash-language-server",
          "css-lsp",
          "html-lsp",
          "json-lsp",
          "haskell-language-server",
          "pyright",
          "r-languageserver",
          "texlab",
          "dotls",
          "svelte-language-server",
          "typescript-language-server",
          "yaml-language-server",
          "clangd",
          "css-lsp",
          "emmet-ls",
          "html-lsp",
          "sqlls",
          -- Additional tools for Python
          "ruff-lsp", -- Faster linter/formatter
          "black",
          "isort",
          -- 'julia-lsp'
          -- 'rust-analyzer',
          --'marksman',
        },
      })

      require("mason-tool-installer").setup({
        ensure_installed = {
          "black",
          "stylua",
          "shfmt",
          "isort",
          "ruff", -- Linter/formatter for Python
          "tree-sitter-cli",
          "jupytext",
        },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          assert(client, "LSP client not found")

          -- Deactivate formatting from lsp (conform/prettier will do it)
          if client.name == "tsserver" or client.name == "ts_ls" then
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end

          -- keymaps LSP
          local function map(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- ---@diagnostic disable-next-line: inject-field
          --  client.server_capabilities.document_formatting = true

          map("gd", vim.lsp.buf.definition, "[g]o to [d]efinition")
          map("gD", vim.lsp.buf.type_definition, "[g]o to type [D]efinition")
          map("<leader>dq", vim.diagnostic.setqflist, "[l]sp diagnostic [q]uickfix")
        end,
      })

      vim.keymap.set("n", "sl", vim.diagnostic.open_float, { desc = "[s]how diagnosis of the current [l]ine" })

      local lsp_flags = {
        allow_incremental_sync = true,
        debounce_text_changes = 150,
      }

      local capabilities = require("blink.cmp").get_lsp_capabilities({}, true)

      -- Improved configuration for R
      lspconfig.r_language_server.setup({
        capabilities = capabilities,
        flags = lsp_flags,
        filetypes = { "r", "rmd", "rmarkdown" },
        settings = {
          r = {
            lsp = {
              rich_documentation = true,
            },
          },
        },
      })

      -- Rest of LSP configurations...
      lspconfig.cssls.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      lspconfig.svelte.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      lspconfig.yamlls.setup({
        capabilities = capabilities,
        flags = lsp_flags,
        settings = {
          yaml = {
            schemaStore = {
              enable = true,
              url = "",
            },
          },
        },
      })

      lspconfig.jsonls.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      lspconfig.texlab.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      lspconfig.dotls.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        flags = lsp_flags,
        filetypes = { "js", "javascript", "typescript", "ojs" },
      })

      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        flags = lsp_flags,
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace",
            },
            runtime = {
              version = "LuaJIT",
            },
            diagnostics = {
              disable = { "trailing-space" },
            },
            workspace = {
              checkThirdParty = false,
            },
            doc = {
              privateName = { "^_" },
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })

      lspconfig.vimls.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      lspconfig.julials.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      lspconfig.bashls.setup({
        capabilities = capabilities,
        flags = lsp_flags,
        filetypes = { "sh", "bash" },
      })

      lspconfig.clangd.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      lspconfig.rust_analyzer.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      -- IMPROVED PYTHON CONFIGURATION
      -- Disable watchers to avoid lag
      if capabilities.workspace == nil then
        capabilities.workspace = {}
        capabilities.workspace.didChangeWatchedFiles = {}
      end
      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

      -- Main pyright configuration
      lspconfig.pyright.setup({
        capabilities = capabilities,
        flags = lsp_flags,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
              -- Additional configurations for better detection
              typeCheckingMode = "basic", -- or "strict" for more checking
              autoImportCompletions = true,
              stubPath = vim.fn.stdpath("data") .. "/lazy/python-type-stubs",
            },
            -- Specify Python interpreter dynamically
            pythonPath = function()
              local cwd = vim.fn.getcwd()
              return get_python_path(cwd)
            end,
          },
        },
        -- Improved function to detect project root
        root_dir = function(fname)
          local root_files = {
            "pyproject.toml",
            "setup.py",
            "setup.cfg",
            "requirements.txt",
            "Pipfile",
            "poetry.lock",
            ".python-version",
            ".git",
          }
          return util.root_pattern(unpack(root_files))(fname)
        end,
        -- Configuration for different virtual environments
        on_new_config = function(new_config, new_root_dir)
          local python_path = get_python_path(new_root_dir)
          new_config.settings.python.pythonPath = python_path
        end,
      })

      -- Optional ruff-lsp configuration (faster than pyright for linting)
      lspconfig.ruff_lsp.setup({
        capabilities = capabilities,
        flags = lsp_flags,
        init_options = {
          settings = {
            args = { "--config", "pyproject.toml" }, -- If using pyproject.toml
          },
        },
        root_dir = function(fname)
          return util.root_pattern("pyproject.toml", "ruff.toml", ".ruff.toml", ".git")(fname)
        end,
      })
    end,
  },
}
