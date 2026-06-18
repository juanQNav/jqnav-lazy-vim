-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.del("n", "<leader><leader>")
vim.keymap.set("n", "<leader>fr", "<cmd>Telescope find_files<CR>", { desc = "Find Files (Root Dir)" })
-- Exit terminal mode using a single Escape press
vim.keymap.set("t", "<C-q>", [[<C-\><C-n>]], { desc = "Terminal Normal Mode" })
vim.keymap.set("i", "<C-q>", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]])
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]])
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]])
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]])

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

-- pdf-view
-- Navigate to the next page in the PDF
vim.keymap.set(
  "n",
  "<leader>jj",
  "<cmd>:lua require('pdfview.renderer').next_page()<CR>",
  { desc = "PDFview: Next page" }
)

-- Navigate to the previous page in the PDF
vim.keymap.set(
  "n",
  "<leader>kk",
  "<cmd>:lua require('pdfview.renderer').previous_page()<CR>",
  { desc = "PDFview: Previous page" }
)

-- Del other Default terminal
vim.keymap.del("n", "<leader>ft")
vim.keymap.del("n", "<leader>fT")
-- Open terminal
vim.keymap.set("n", "<leader>ct", function()
  require("snacks").terminal(nil, { cwd = LazyVim.root() })
end, { desc = "Terminal (Root Dir)" })
