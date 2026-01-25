return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  ft = { "markdown" },
  config = function()
    require("render-markdown").setup({
      enabled = true,
      latex = {
        enabled = true,
        converter = "latex2text",
        highlight = "RenderMarkdownMath", -- String, no table
      },
      checkbox = {
        unchecked = {
          icon = "☐", -- Customize icon
          -- highlight = "RenderMarkdownChecked",
          -- scope_highlight = "RenderMarkdownChecked",
        },
        checked = {
          icon = "󰄲", -- Customize icon
          -- highlight = "RenderMarkdownChecked",
          -- scope_highlight = "RenderMarkdownChecked",
        },
        right_pad = 6,
        left_pad = 0,
      },
    })
  end,
}
