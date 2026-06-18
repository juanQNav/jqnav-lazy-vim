return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  lazy = false,
  config = function()
    -- Keep transparency state globally so it persists during the session
    vim.g.catppuccin_transparent_background = vim.g.catppuccin_transparent_background or true

    -- Apply theme using current transparency state
    local function apply_catppuccin()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        transparent_background = vim.g.catppuccin_transparent_background,
        float = {
          transparent = false, -- enable transparent floating windows
          solid = false, -- use solid styling for floating windows, see |winborder|
        },
        show_end_of_buffer = false, -- show the '~' characters after the end of buffers
        term_colors = false,
        dim_inactive = {
          enabled = false,
          shade = "dark",
          percentage = 0.15,
        },
        no_italic = false, -- Force no italic
        no_bold = false, -- Force no bold
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
        custom_highlights = {},
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          telescope = true,
          render_markdown = true,
          snacks = {
            enabled = false,
            indent_scope_color = "text", -- catppuccin color (eg. `lavender`) Default: text
          },
          blink_cmp = {
            style = "bordered",
          },
          notify = false,
          mini = false,
        },
      })

      -- setup must be called before loading
      vim.cmd.colorscheme("catppuccin")
    end

    -- WhichKey dynamic label based on transparency state
    local function transparent_state_text()
      if vim.g.catppuccin_transparent_background then
        return " Disable Transparent Background"
      end
      return " Enable Transparent Background"
    end

    local function refresh_which_key_toggle()
      local ok, wk = pcall(require, "which-key")
      if not ok then
        return
      end

      -- Update WhichKey label dynamically
      wk.add({
        { "<leader>ut", desc = transparent_state_text(), mode = "n" },
      })
    end

    -- Initial load
    apply_catppuccin()
    refresh_which_key_toggle()

    -- User command: :CatppuccinToggleTransparent
    vim.api.nvim_create_user_command("CatppuccinToggleTransparent", function()
      vim.g.catppuccin_transparent_background = not vim.g.catppuccin_transparent_background
      apply_catppuccin()
      refresh_which_key_toggle()
      vim.notify(
        "Catppuccin transparent background: " .. tostring(vim.g.catppuccin_transparent_background),
        vim.log.levels.INFO
      )
    end, { desc = "Toggle Catppuccin transparent background" })

    -- Keymap: <leader>ut
    vim.keymap.set("n", "<leader>ut", "<cmd>CatppuccinToggleTransparent<CR>", {
      desc = "Toggle transparency",
      silent = true,
    })
  end,
}
