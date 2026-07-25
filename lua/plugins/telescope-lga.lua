return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-live-grep-args.nvim",
        version = "^1.0.0",
      },
      {
        "nvim-telescope/telescope-file-browser.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
      },
    },
    config = function()
      local telescope = require("telescope")
      local lga_actions = require("telescope-live-grep-args.actions")

      telescope.setup({
        extensions = {
          file_browser = {
            path = "~/",
            hidden = true,
            respect_gitignore = true,
          },
          live_grep_args = {
            auto_quoting = true,
            mappings = {
              i = {
                ["<C-k>"] = lga_actions.quote_prompt(),
                ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                ["<C-space>"] = lga_actions.to_fuzzy_refine,
              },
            },
          },
        },
      })

      telescope.load_extension("live_grep_args")
      telescope.load_extension("file_browser")

      -- 🗝️  Atajo de teclado para Live Grep Args
      vim.keymap.set("n", "<leader>fg", function()
        telescope.extensions.live_grep_args.live_grep_args()
      end, { desc = "Live Grep with Args" })
    end,
  },
}
