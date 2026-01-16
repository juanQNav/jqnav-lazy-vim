-- This file contains the configuration for the obsidian.nvim plugin in Neovim.

return {
  {
    -- Plugin: obsidian.nvim (Community Fork with blink.cmp support)
    -- URL: https://github.com/obsidian-nvim/obsidian.nvim
    -- Description: A Neovim plugin for integrating with Obsidian, a powerful knowledge base that works on top of a local folder of plain text Markdown files.
    "obsidian-nvim/obsidian.nvim", -- Using the community fork with blink support
    version = "*", -- Use the latest release instead of the latest commit (recommended)
    lazy = true, -- Don't load immediately
    ft = "markdown", -- También cargar con cualquier archivo markdown
    cmd = { "ObsidianOpen", "ObsidianNew", "ObsidianQuickSwitch", "ObsidianToday", "ObsidianSearch" },
    keys = {
      { "<leader>oo", "<cmd>ObsidianQuickSwitch<cr>", desc = "Obsidian Quick Switch" },
      { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "Obsidian New Note" },
      { "<leader>ot", "<cmd>ObsidianToday<cr>", desc = "Obsidian Today" },
      -- Custom keymaps (replacing deprecated mappings)
      { "<leader>of", "<cmd>ObsidianFollowLink<cr>", desc = "Obsidian Follow Link", ft = "markdown" },
      { "<leader>od", "<cmd>ObsidianToggleCheckbox<cr>", desc = "Obsidian Toggle Checkbox", ft = "markdown" },
      {
        "<leader>onn",
        function()
          vim.ui.input({ prompt = "New note name: " }, function(input)
            if input and input ~= "" then
              local client = require("obsidian").get_client()
              local note = client:new_note(input)
              if note then
                client:open_note(note)
              end
            end
          end)
        end,
        desc = "Obsidian New Named Note",
        ft = "markdown",
      },
      {
        "<leader>om",
        function()
          local client = require("obsidian").get_client()
          local note = client:current_note()
          if not note then
            vim.notify("No note found in current buffer", vim.log.levels.WARN)
            return
          end

          local vault_path = client:vault_root()
          if not vault_path:exists() then
            vim.notify("Could not determine vault root", vim.log.levels.ERROR)
            return
          end

          local scan = require("plenary.scandir")

          -- Exocortex folders
          local exocortex_folders = {
            limbus = true,
            templates = true,
          }
          local existing_folders = {}

          local subdirs = scan.scan_dir(tostring(vault_path), {
            only_dirs = true,
            depth = 2,
          })

          for _, subdir in ipairs(subdirs) do
            local relative = subdir:gsub(tostring(vault_path) .. "/", "")
            table.insert(existing_folders, relative)
          end

          -- Scan for existing folders within Exocortex structure
          for _, base_folder in pairs(exocortex_folders) do
            local base_path = vault_path / base_folder
            if base_path:exists() then
              table.insert(existing_folders, base_folder)

              -- Scan subdirectories
              local subdirs = scan.scan_dir(tostring(base_path), {
                only_dirs = true,
                depth = 2,
              })

              for _, subdir in ipairs(subdirs) do
                local relative = subdir:gsub(tostring(vault_path) .. "/", "")
                local folder_name = relative:match("^([^/]+)")
                if not exocortex_folders[folder_name] then
                  table.insert(existing_folders, relative)
                end
              end
            end
          end

          -- Sort folders alphabetically
          table.sort(existing_folders)
          -- Add option to create new folder at the beginning
          local options = vim.deepcopy(existing_folders)
          vim.list_extend(options, { "  Create new folder..." })

          vim.ui.select(options, {
            prompt = "Move note to:",
            format_item = function(item)
              if item == "  Create new folder..." then
                return item
              end
              return "  " .. item
            end,
          }, function(choice)
            if not choice then
              return
            end

            local function move_note(target_folder)
              local new_dir = vault_path / target_folder
              new_dir:mkdir({ parents = true, exists_ok = true })

              local old_path = note.path
              local new_path = new_dir / old_path.name

              -- Check if file already exists at destination
              if vim.loop.fs_stat(tostring(new_path)) then
                vim.notify(string.format("File already exists at %s", target_folder), vim.log.levels.ERROR)
                return
              end

              vim.loop.fs_rename(tostring(old_path), tostring(new_path))
              vim.cmd("bdelete")
              vim.cmd("edit " .. tostring(new_path))

              vim.notify(string.format("✓ Moved to %s", target_folder), vim.log.levels.INFO)
            end

            if choice == "  Create new folder..." then
              vim.ui.input({
                prompt = "New folder path (e.g., projects/myproject): ",
              }, function(new_folder)
                if new_folder and new_folder ~= "" then
                  move_note(new_folder)
                end
              end)
            else
              move_note(choice)
            end
          end)
        end,
        desc = "Obsidian Move Note",
        ft = "markdown",
      },
    },
    event = {
      -- Load when opening markdown files in the Obsidian workspace
      "BufReadPre "
        .. vim.fn.expand("~")
        .. "/Documents/Exocortex/**.md",
      "BufNewFile " .. vim.fn.expand("~") .. "/Documents/Exocortex/**.md",
    },
    dependencies = {
      -- Dependency: plenary.nvim
      -- URL: https://github.com/nvim-lua/plenary.nvim
      -- Description: A Lua utility library for Neovim.
      "nvim-lua/plenary.nvim",
      -- Dependency: blink.cmp
      -- URL: https://github.com/saghen/blink.cmp
      -- Description: A completion plugin for neovim.
      "saghen/blink.cmp",
    },

    opts = {
      -- Define workspaces for Obsidian
      workspaces = {
        {
          name = "Exocortex", -- Name of the workspace
          path = "/home/jqnav/Documents/Exocortex", -- Path to the notes directory
        },
      },

      -- Completion settings
      completion = {
        blink = true, -- Enable blink.cmp integration (community fork feature)
        min_chars = 1, -- Start suggesting after 1 character
      },

      notes_subdir = "limbus", -- Subdirectory for notes
      new_notes_location = "limbus", -- Location for new notes

      -- Settings for attachments
      attachments = {
        img_folder = "files", -- Folder for image attachments
      },

      -- Settings for daily notes
      daily_notes = {
        template = "note", -- Template for daily notes
      },

      -- Function to generate frontmatter for notes
      note_frontmatter_func = function(note)
        -- This is equivalent to the default frontmatter function.
        local out = { id = note.id, aliases = note.aliases, tags = note.tags }

        -- `note.metadata` contains any manually added fields in the frontmatter.
        -- So here we just make sure those fields are kept in the frontmatter.
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end
        return out
      end,

      -- Function to generate note IDs
      note_id_func = function(title)
        -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
        -- In this case a note with the title 'My new note' will be given an ID that looks
        -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
        local suffix = ""
        if title ~= nil then
          -- If title is given, transform it into valid file name.
          suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        else
          -- If title is nil, just add 4 random uppercase letters to the suffix.
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
        end
        return tostring(os.time()) .. "-" .. suffix
      end,

      -- Settings for templates
      templates = {
        subdir = "templates", -- Subdirectory for templates
        date_format = "%Y-%m-%d-%a", -- Date format for templates
        gtime_format = "%H:%M", -- Time format for templates
        tags = "", -- Default tags for templates
      },
    },
  },
}
