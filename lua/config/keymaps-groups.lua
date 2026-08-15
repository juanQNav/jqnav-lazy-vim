-- Keymaps groups for which-key.nvim
local wk = require("which-key")

wk.add({
  -- ai
  { "<leader>a", group = "AI", icon = "󰚩" },
  -- obsidian
  { "<leader>o", group = "Obsidian", icon = "󰠮" },
  -- idiom
  { "<leader>i", group = "Idiom (spell)", icon = "󰌗" },
  -- pdf preview
  { "<leader>p", group = "PDF Preview", icon = "󰈔" },
})
