return {
  "brianhuster/live-preview.nvim",
  dependencies = {
    -- You can choose one of the following pickers
    "nvim-telescope/telescope.nvim",
    -- "ibhagwan/fzf-lua",
    -- "echasnovski/mini.pick",
    -- "folke/snacks.nvim",
  },
  cmd = { "LivePreview" },
  keys = {
    { "<leader>cp", "<cmd>LivePreview start<cr>", desc = "HTML Live Preview" },
  },
  opts = {},
}
