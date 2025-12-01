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
    })
  end,
}
