return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      ignored = true, -- Set to true  to include ignored files "alt + i" and "H" to show hide files
      sources = {
        explorer = {
          -- Performance: disable heavy features for faster loading
          git_status = true, -- skip git status computation
          git_untracked = false, -- skip untracked files check
          diagnostics = true, -- skip LSP diagnostics
          watch = true, -- skip file system watcher
          -- Keep tree view (fast enough)
          tree = true,
          formatters = {
            file = { filename_only = true },
          },
        },
      },
    },
  },
}
