-- lua/plugins/prettier.lua
return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    if opts.formatters_by_ft then
      --  only web
      opts.formatters_by_ft = vim.tbl_extend("force", opts.formatters_by_ft, {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        vue = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        less = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        -- Explicity exclude Python
        python = { "ruff_format", "ruff_organize_imports" },
      })
    end
    return opts
  end,
}
