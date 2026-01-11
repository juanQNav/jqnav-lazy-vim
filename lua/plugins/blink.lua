return {
  {
    "giuxtaposition/blink-cmp-copilot",
    dependencies = { "zbirenbaum/copilot.lua" },
  },
  {
    "saghen/blink.cmp",
    dependencies = { "giuxtaposition/blink-cmp-copilot" },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },
      completion = {
        ghost_text = {
          enabled = true,
        },
      },
      snippets = {
        jump = function(direction)
          require("luasnip").jump(direction)
        end,
      },
      cmdline = {
        keymap = { preset = "inherit" },
        completion = { menu = { auto_show = true } },
      },
      sources = {
        default = { "lsp", "copilot", "snippets", "buffer", "path" },
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-cmp-copilot",
            score_offset = 100, -- High priority for Copilot suggestions
            async = true,
          },
        },
        per_filetype = {
          codecompanion = { "codecompanion" },
        },
      },
    },
  },
}
