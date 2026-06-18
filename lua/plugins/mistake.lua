return {
  "ck-zhang/mistake.nvim",
  config = function()
    local plugin = require("mistake")
    vim.defer_fn(function()
      plugin.setup()
    end, 500)

    vim.keymap.set("n", "<leader>ma", plugin.add_entry, { desc = "[M]istake [A]dd entry" })
    vim.keymap.set("n", "<leader>me", plugin.edit_entries, { desc = "[M]istake [E]dit entries" })
    vim.keymap.set("n", "<leader>mc", plugin.add_entry_under_cursor, { desc = "[M]istake add [C]urrent word" })
  end,
}
