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
        require("opencode").ask("")
      end,
      mode = { "n", "x" },
      desc = "OpenCode ask",
    },
    {
      "<leader>aoI",
      function()
        require("opencode").ask("@this: ")
      end,
      mode = { "n", "x" },
      desc = "OpenCode ask with context",
    },
    {
      "<leader>aob",
      function()
        require("opencode").ask("@file ")
      end,
      mode = { "n", "x" },
      desc = "OpenCode ask about buffer",
    },
    -- custom ruquest docstring
    {
      "<leader>aod",
      function()
        require("opencode").ask("@this: Complete the missing docstring in function: ")
      end,
      mode = { "n", "x" },
      desc = "OPencode complete missing docstring",
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
            .. "Complete only the TODOs from selection. The topic to be covered is: "
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
          "Review the contents in the staging area and make an appropiate conventional commit."
        )
      end,
      mode = { "n", "x" },
      desc = "OpenCode git commit",
    },
    {
      "<leader>aogf",
      function()
        require("opencode").ask(
          "Make branch, commit, push and PR for the changes in the staging area. The PR should be ready to merge."
        )
      end,
      mode = { "n", "x" },
      desc = "OpenCode git full",
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
