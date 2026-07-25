return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      ignored = true, -- Set to true  to include ignored files "alt + i" and "H" to show hide files
      sources = {
        explorer = {
          -- Performance: disable heavy features for faster loading
          git_ignored = false, -- skip (false) git ignored files check
          git_status = true, -- skip (false) git status computation
          git_untracked = true, -- skip (false) untracked files check
          diagnostics = true, -- skip (false) LSP diagnostics
          watch = true, -- skip (false) file system watcher
          -- Keep tree view (fast enough)
          tree = true,
          formatters = {
            file = { filename_only = true },
          },
          focus = "list",
        },
      },
    },
  },
}
