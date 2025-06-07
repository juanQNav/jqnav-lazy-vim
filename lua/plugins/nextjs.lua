return {

  -- LSPs (Languages)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tsserver = {}, -- Suport to TypeScript / JavaScript
        eslint = {}, -- Linter
        tailwindcss = {}, -- Suport to Tailwind CSS
      },
    },
  },

  -- snippets (React, etc.)
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  -- Prettier
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
      },
    },
  },
}
