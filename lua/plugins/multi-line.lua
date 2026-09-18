return {
  "mg979/vim-visual-multi",
  event = { "BufReadPost", "BufNewFile" },
  init = function()
    vim.g.VM_maps = {
      ["Add Cursor Down"] = "<C-M-J>",
      ["Add Cursor Up"] = "<C-M-K>",
      -- ["Select All"] = "<C-a>",
    }
  end,
}
