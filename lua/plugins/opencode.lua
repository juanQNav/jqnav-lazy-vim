local opencode_cmd = "opencode --port --agent gentle-orchestrator"
local snacks_terminal_opts = {
  win = {
    position = "right",
    enter = false,
  },
}

return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  keys = {
    {
      "<leader>aoa",
      function()
        require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts)
      end,
      mode = { "n", "x" },
      desc = "Toggle OpenCode",
    },
    {
      "<leader>aos",
      function()
        require("opencode").select({ submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode select",
    },
    {
      "<leader>aoi",
      function()
        require("opencode").ask("", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode ask",
    },
    {
      "<leader>aoI",
      function()
        require("opencode").ask("@this: ", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode ask with context",
    },
    {
      "<leader>aob",
      function()
        require("opencode").ask("@file ", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "OpenCode ask about buffer",
    },
    -- custom promt for notebooks with mcp notebooklm
    {
      "<leader>aon",
      mode = { "n", "x" },
      desc = "OpenCode with NotebookLM",
    },
    {
      "<leader>aont",
      function()
        require("opencode").ask(
          "@this:  Read AGENTS.md for all conventions (note IDs, wiki links, templetes)."
            .. "Complete only the TODOs from selection. The topic to be covered is: ",
          { submit = false }
        )
      end,
      mode = { "n", "x" },
      desc = "OpenCode complete TODOs with NotebookLM",
    },
    -- custom promt for git
    {
      "<leader>aog",
      mode = { "n", "x" },
      desc = "OpenCode git",
    },
    {
      "<leader>aogc",
      function()
        require("opencode").ask(
          "Review the contents in the staging area and make an appropiate conventional commit.",
          { submit = false }
        )
      end,
      mode = { "n", "x" },
      desc = "OpenCode git commit",
    },
  },
  config = function()
    vim.g.opencode_opts = {
      server = {
        start = function()
          require("snacks.terminal").open(opencode_cmd, snacks_terminal_opts)
        end,
      },
    }
    vim.o.autoread = true
  end,
}
