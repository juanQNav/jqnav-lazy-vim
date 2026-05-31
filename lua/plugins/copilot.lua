-- IMPORTANT: First time setup requires running `:Copilot auth` in Neovim to authenticate
-- with GitHub. Without this, Copilot suggestions will not work.
--
-- Helper: current label based on toggle state
local function copilot_label()
  if vim.g.blink_copilot_enabled == nil then
    vim.g.blink_copilot_enabled = true
  end
  return vim.g.blink_copilot_enabled and " Disable Copilot suggestions" or " Enalble Copilot suggestions"
end

-- Helper: refresh WhichKey label
local function refresh_copilot_wk()
  local ok, wk = pcall(require, "which-key")
  if not ok then
    return
  end

  wk.add({
    { "<leader>at", desc = copilot_label() },
  })
end

return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  init = function()
    refresh_copilot_wk()
  end,

  opts = {
    suggestion = {
      enabled = false, -- Disabled because we use blink.cmp
      auto_trigger = false,
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
        -- Toggle Copilot source for blink.cmp
        if vim.g.blink_copilot_enabled == nil then
          vim.g.blink_copilot_enabled = true
        end

        vim.g.blink_copilot_enabled = not vim.g.blink_copilot_enabled
        refresh_copilot_wk()

        vim.notify(
          vim.g.blink_copilot_enabled and "✅ Copilot suggestions enabled" or "🚫 Copilot suggestions disabled",
          vim.log.levels.INFO
        )
      end,
      desc = "Toggle Copilot suggestions",
      mode = "n",
    },
    {
      "<leader>ai",
      function()
        local config = require("blink.cmp.config")
        local sources = config.sources.default

        -- Resolve dynamic sources function
        if type(sources) == "function" then
          sources = sources()
        end

        vim.notify("Active sources: " .. vim.inspect(sources), vim.log.levels.INFO)
      end,
      desc = "Show active completion sources",
      mode = "n",
    },
    -- Debug: Check Copilot status
    {
      "<leader>ad",
      function()
        local msgs = {}

        -- Check if copilot.lua is loaded
        local copilot_loaded = pcall(require, "copilot")
        table.insert(msgs, "copilot.lua loaded: " .. (copilot_loaded and "✅" or "❌"))

        -- Check if blink-cmp-copilot is available
        local blink_copilot_ok = pcall(require, "blink-cmp-copilot")
        table.insert(msgs, "blink-cmp-copilot: " .. (blink_copilot_ok and "✅" or "❌"))

        -- Check toggle state
        local enabled = vim.g.blink_copilot_enabled ~= false
        table.insert(msgs, "Copilot toggle: " .. (enabled and "✅ enabled" or "🚫 disabled"))

        -- Check if copilot is authenticated
        if copilot_loaded then
          local auth_status = "unknown"
          local ok, result = pcall(function()
            return require("copilot.api").status.data.status
          end)
          if ok then
            auth_status = result
          end
          table.insert(msgs, "Copilot auth status: " .. auth_status)
        end

        vim.notify(table.concat(msgs, "\n"), vim.log.levels.INFO)
      end,
      desc = "Debug Copilot status",
      mode = "n",
    },
  },
}
