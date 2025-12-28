-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.del("n", "<leader><leader>")
vim.keymap.set("n", "<leader>fr", "<cmd>Telescope find_files<CR>", { desc = "Find Files (Root Dir)" })

-- Toggle Copilot suggestions (autocompletions) without affecting Copilot Chat
_G.copilot_suggestions_enabled = true

vim.keymap.set("n", "<leader>ct", function()
  if _G.copilot_suggestions_enabled then
    vim.cmd("Copilot disable")
    _G.copilot_suggestions_enabled = false
    print("Copilot suggestions disabled")
  else
    vim.cmd("Copilot enable")
    _G.copilot_suggestions_enabled = true
    print("Copilot suggestions enabled")
  end
end, { desc = "Toggle Copilot suggestions" })

-- keymap rename
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local opts = { buffer = event.buf, desc = "Rename symbol" }
    vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)
  end,
})
