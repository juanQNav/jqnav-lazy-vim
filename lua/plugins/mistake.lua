return {
  "ck-zhang/mistake.nvim",
  config = function()
    local mistake = require("mistake")

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "text" },
      callback = function(ev)
        mistake.setup()
        local b = ev.buf
        vim.keymap.set("n", "<leader>ma", mistake.add_entry, { buffer = b, desc = "[M]istake [A]dd entry" })
        vim.keymap.set("n", "<leader>me", mistake.edit_entries, { buffer = b, desc = "[M]istake [E]dit entries" })
        vim.keymap.set(
          "n",
          "<leader>mc",
          mistake.add_entry_under_cursor,
          { buffer = b, desc = "[M]istake add [C]urrent word" }
        )
      end,
    })
  end,
}
