return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
      debounce = 75,
      keymap = {
        accept = "<M-l>",
        accept_word = false,
        accept_line = false,
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
    },
    panel = { enabled = false },
    filetypes = {
      yaml = false,
      markdown = false,
      help = false,
      gitcommit = false,
      gitrebase = false,
      hgcommit = false,
      svn = false,
      cvs = false,
      ["."] = false,
      ["copilot-chat"] = false,
    },
  },
  keys = {
    {
      "<leader>at",
      function()
        local copilot = require("copilot.suggestion")
        if _G.copilot_suggestions_enabled == nil then
          _G.copilot_suggestions_enabled = true
        end

        if _G.copilot_suggestions_enabled then
          copilot.toggle_auto_trigger()
          _G.copilot_suggestions_enabled = false
          vim.notify("🚫 Copilot suggestions disabled", vim.log.levels.INFO)
        else
          copilot.toggle_auto_trigger()
          _G.copilot_suggestions_enabled = true
          vim.notify("✅ Copilot suggestions enabled", vim.log.levels.INFO)
        end
      end,
      desc = "Toggle Copilot suggestions",
      mode = "n",
    },
  },
}
