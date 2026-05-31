local function get_default_sources()
  -- Default value for the Copilot toggle
  if vim.g.blink_copilot_enabled == nil then
    vim.g.blink_copilot_enabled = true
  end

  local sources = { "lsp", "snippets", "buffer", "path" }

  -- Insert Copilot only when enabled
  if vim.g.blink_copilot_enabled then
    table.insert(sources, 2, "copilot")
  end

  return sources
end

return {
  {
    "saghen/blink.cmp",
    dependencies = {
      "giuxtaposition/blink-cmp-copilot",
      "zbirenbaum/copilot.lua", -- Ensure copilot.lua loads first
      "saghen/blink.nvim",
    },
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
        sources = {},
      },
      sources = {
        default = get_default_sources,
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-cmp-copilot",
            score_offset = 100,
            async = true,
            -- Ensure copilot items are clearly marked
            transform_items = function(_, items)
              local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
              local kind_idx = #CompletionItemKind + 1
              CompletionItemKind[kind_idx] = "Copilot"
              for _, item in ipairs(items) do
                item.kind = kind_idx
              end
              return items
            end,
          },
          -- Obsidian providers are registered automatically by obsidian.nvim
          -- DO NOT define them here to avoid conflicts
        },
        per_filetype = {
          markdown = { "lsp", "obsidian", "obsidian_new", "obsidian_tags", "snippets", "buffer", "path" },
          codecompanion = { "codecompanion" },
        },
      },
    },
  },
}
