return {
  "ojroques/nvim-osc52",
  config = function()
    require("osc52").setup({
      max_length = 0, -- unlimited
      silent = false,
      trim = false,
    })

    -- Copy in visual mode
    vim.keymap.set("v", "<leader>y", require("osc52").copy_visual)

    -- Copy in normal mode example <leader>yy copy one line
    vim.keymap.set("n", "<leader>yy", function()
      require("osc52").copy_operator()()
    end)
  end,
}
