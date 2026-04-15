local util = require("lazyvim.util")

return {
  -- Treesitter para C#
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "c_sharp" })
      end
    end,
  },

  -- LSP C#
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        omnisharp = {},
      },
      setup = {
        omnisharp = function()
          util.on_attach(function(client, _)
            if client.name == "omnisharp" then
              local tokens = client.server_capabilities.semanticTokensProvider

              if tokens and tokens.legend then
                for i, v in ipairs(tokens.legend.tokenModifiers or {}) do
                  tokens.legend.tokenModifiers[i] = v:gsub(" ", "_")
                end
                for i, v in ipairs(tokens.legend.tokenTypes or {}) do
                  tokens.legend.tokenTypes[i] = v:gsub(" ", "_")
                end
              end
            end
          end)

          return false
        end,
      },
    },

    -- auto-start
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "cs",
        callback = function()
          vim.schedule(function()
            vim.cmd("LspStart omnisharp")
          end)
        end,
      })
    end,
  },
}
