return {
  {
    "saghen/blink.cmp",
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
        default = { "lsp", "snippets", "buffer", "path" },
        per_filetype = {
          codecompanion = { "codecompanion" },
        },
      },
    },
  },
}
