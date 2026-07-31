-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.diagnostic.config({
  virtual_text = true,
})

-- Spell check: English + Spanish
vim.opt.spelllang = { "en", "es" }

-- Auto-download Spanish spell dictionary if missing
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local spell_dir = vim.fn.stdpath("data") .. "/site/spell"
    local spl_file = spell_dir .. "/es.utf-8.spl"
    if vim.fn.filereadable(spl_file) == 0 then
      vim.fn.mkdir(spell_dir, "p")
      vim.cmd("set spelllang=es")
      vim.cmd("set spell")
    end
  end,
})
