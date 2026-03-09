-- lua/plugins/conform.lua
return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    -- detect configuration file for ruff
    local function has_ruff()
      local root_files = { "ruff.toml", ".ruff.toml" }
      for _, file in ipairs(root_files) do
        if vim.fn.filereadable(file) == 1 then
          return true
        end
      end
      -- check pyproject.toml
      if vim.fn.filereadable("pyproject.toml") == 1 then
        local content = vim.fn.readfile("pyproject.toml")
        for _, line in ipairs(content) do
          if line:match("%[tool%.ruff") then
            return true
          end
          if line:match("ruff") or line:match('"ruff[>=') then
            return true
          end
        end
      end

      return false
    end

    opts.formatters_by_ft = vim.tbl_extend("force", opts.formatters_by_ft or {}, {
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      vue = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      less = { "prettier" },
      html = { "prettier" },
      htmlangular = { "prettier" },
      json = { "prettier" },
      jsonc = {},
      yaml = { "prettier" },
      markdown = { "prettier" },
      tex = { "latexindent" },
      -- Explicity exclude Python
      python = has_ruff() and { "ruff_format", "ruff_organize_imports" } or {},
    })

    -- cofigure prettier to use the project configuration file
    opts.formatters = opts.formatters or {}
    opts.formatters.prettier = {
      command = "prettier",
      args = { "--stdin-filepath", "$FILENAME" },
      stdin = true,
      cwd = require("conform.util").root_file({ ".prettierrc", ".prettierrc.json", "prettier.config.js" }),
    }

    -- LaTeX: latexindent with line-break modification enabled
    opts.formatters.latexindent = {
      command = "latexindent",
      args = { "-l", "-m" },
      stdin = true,
    }
    return opts
  end,
}
