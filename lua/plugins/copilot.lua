return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
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
  -- The toggle will now control the blink.cmp source
  keys = {
    {
      "<leader>at",
      function()
        local config = require("blink.cmp.config")
        local sources = config.sources.default

        -- If sources is a function, invoke it to get the table
        if type(sources) == "function" then
          sources = sources()
        end

        local has_copilot = vim.tbl_contains(sources, "copilot")

        if has_copilot then
          -- Remove copilot from source
          local new_sources = vim.tbl_filter(function(v)
            return v ~= "copilot"
          end, sources)
          config.sources.default = new_sources
          vim.notify("🚫 Copilot suggestions disabled", vim.log.levels.INFO)
        else
          -- Add copilto to sourcers
          local new_sources = vim.deepcopy(sources)
          table.insert(new_sources, 2, "copilot")
          config.sources.default = new_sources
          vim.notify("✅ Copilot suggestions enabled", vim.log.levels.INFO)
        end
      end,
      desc = "Toggle Copilot suggestions",
      mode = "n",
    },
    {
      "<leader>ai",
      function()
        local config = require("blink.cmp.config")
        local sources = config.sources.default

        if type(sources) == "function" then
          sources = sources()
        end

        vim.notify("Active sources: " .. vim.inspect(sources), vim.log.levels.INFO)
      end,
      desc = "Show active completion sources",
      mode = "n",
    },
  },
}
