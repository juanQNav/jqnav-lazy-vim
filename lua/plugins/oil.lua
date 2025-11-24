return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  dependencies = {
    { "nvim-mini/mini.icons", opts = {} },
  },
  keys = { { "-", "<CMD>Oil<CR>", desc = "Open parent directory", mode = "n" } },
  config = function()
    require("oil").setup({
      keymaps = {
        ["q"] = "actions.close",
        ["g."] = { "actions.toggle_hidden", mode = "n" },
      },
    })
  end,
  -- directoryependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
}
