return {
  "3rd/diagram.nvim",
  dependencies = {
    { "3rd/image.nvim", opts = {} }, -- you'd probably want to configure image.nvim manually instead of doing this
  },
  opts = { -- you can just pass {}, defaults below
    events = {
      render_buffer = { "InsertLeave", "BufWinEnter" },
      clear_buffer = { "BufLeave" },
    },
    renderer_options = {
      mermaid = {
        background = "transparent", -- nil | "transparent" | "white" | "#hex"
        theme = "dark", -- nil | "default" | "dark" | "forest" | "neutral"
        scale = 2, -- nil | 1 (default) | 2  | 3 | ...
        width = 800, -- nil | 800 | 400 | ...
        height = 600, -- nil | 600 | 300 | ...
        cli_args = { "-p", "~/.config/nvim/lua/plugins/mermaid-config/puppeteer-config.json" }, -- nil | { "--no-sandbox" } | { "-p", "/path/to/puppeteer" } | ...
      },
    },
  },
  key = {
    {
      "K", -- or any key you prefer
      function()
        require("diagram").show_diagram_hover()
      end,
      mode = "n",
      ft = { "markdown", "norg" }, -- only in these filetypes
      desc = "Show diagram in new tab",
    },
  },
}
