-- lua/plugins/nvim-lint.lua
return {
  "mfussenegger/nvim-lint",
  opts = function(_, opts)
    opts.linters_by_ft = opts.linters_by_ft or {}
    opts.linters_by_ft.markdown = { "markdownlint-cli2" }

    -- Only enable flake8 when a virtual environment is active
    if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
      opts.linters_by_ft.python = { "flake8" }
      local flake8 = require("lint").linters.flake8
      if flake8 then
        flake8.cmd = vim.env.VIRTUAL_ENV .. "/bin/flake8"
      end
    end

    return opts
  end,
}
