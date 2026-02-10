return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  lazy = false,
  config = function()
    require("catppuccin").setup({
      flavour = "macchiato", -- latte, frappe, macchiato, mocha
      background = {
        light = "latte",
        dark = "mocha",
      },
      transparent_background = true,
      show_end_of_buffer = false,
      term_colors = false,
      dim_inactive = {
        enabled = false,
        shade = "dark",
        percentage = 0.15,
      },
      no_italic = false,
      no_bold = false,
      no_underline = false,
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
      },
      color_overrides = {},
      custom_highlights = function(colors)
        return {
          -- Make floating windows transparent
          NormalFloat = { bg = "NONE" },
        }
      end,
      default_integrations = true,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        mini = {
          enabled = true,
          indentscope_color = "",
        },
      },
    })

    vim.cmd.colorscheme("catppuccin")

    -- function for toggle transparency
    local transparent_bg = true
    _G.toggle_transparency = function()
      transparent_bg = not transparent_bg
      require("catppuccin").setup({
        transparent_background = transparent_bg,
      })
      custom_highlights = {}, vim.cmd.colorscheme("catppuccin")
    end

    -- keymap to toggle transparency
    vim.keymap.set("n", "<leader>ut", "<cmd>lua toggle_transparency()<CR>", { desc = "Toggle Transparency" })
  end,
}
