return {
  "3rd/diagram.nvim",
  dependencies = {
    {
      "3rd/image.nvim",
      opts = {
        backend = "sixel",
      },
    },
  },
  opts = { -- you can just pass {}, defaults below
    events = {
      -- render_buffer = { "InsertLeave", "BufWinEnter" },
      -- render_buffer = { "BufWinEnter" },
      render_buffer = { "BufWinEnter", "BufReadPost" },
      clear_buffer = { "BufLeave" },
    },
    renderer_options = {
      mermaid = {
        background = "transparent", -- nil | "transparent" | "white" | "#hex"
        theme = "dark", -- nil | "default" | "dark" | "forest" | "neutral"
        scale = 1, -- nil | 1 (default) | 2  | 3 | ...
        width = 1000, -- nil | 800 | 400 | ...
        height = 1000, -- nil | 600 | 300 | ...
        cli_args = { "-p", "~/.config/nvim/lua/plugins/mermaid-config/puppeteer-config.json" }, -- nil | { "--no-sandbox" } | { "-p", "/path/to/puppeteer" } | ...
      },
    },
  },
  config = function(_, opts)
    -- Wrap the entire setup in pcall. diagram.nvim's setup fires an
    -- initial render that captures render_buffer via a local closure
    -- inside the autocmd, so monkey-patching M.render_buffer is
    -- useless. The only way to keep lazy from surfacing the harmless
    -- E565 from image.nvim's Sixel backend (wezterm) is to catch it
    -- here, at the outermost layer.
    local ok, err = pcall(function()
      local diagram = require("diagram")
      local original = diagram.render_buffer
      diagram.render_buffer = function(bufnr)
        pcall(original, bufnr)
      end
      diagram.setup(opts)
    end)
    if not ok and not tostring(err):match("E565") then
      vim.notify("Diagram setup error: " .. err, vim.log.levels.ERROR)
    end
  end,
  keys = {
    {
      "K", -- or any key you prefer
      function()
        -- Defer to a safe autocmd context and swallow the harmless
        -- E565 race that image.nvim Sixel backend throws in wezterm.
        vim.schedule(function()
          local ok, err = pcall(require("diagram").show_diagram_hover)
          if not ok and not tostring(err):match("E565") then
            vim.notify("Diagram error: " .. err, vim.log.levels.ERROR)
          end
        end)
      end,
      mode = "n",
      ft = { "markdown", "norg" }, -- only in these filetypes
      desc = "Show diagram in new tab",
    },
  },
}
