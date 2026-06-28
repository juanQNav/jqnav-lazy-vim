-- This file contains the configuration for the obsidian.nvim plugin in Neovim.

return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    cmd = { "Obsidian" },

    keys = {
      { "<leader>oo", "<cmd>Obsidian quick_switch<cr>", desc = "Obsidian Quick Switch" },
      { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Obsidian Search" },
      { "<leader>oa", "<cmd>Obsidian open<cr>", desc = "Obsidian Open Vault" },
      {
        "<leader>of",
        "<cmd>Obsidian follow_link<cr>",
        desc = "Obsidian Follow Link",
        ft = "markdown",
      },

      {
        "<leader>od",
        "<cmd>Obsidian toggle_checkbox<cr>",
        desc = "Obsidian Toggle Checkbox",
        ft = "markdown",
      },

      -- =========================
      -- NEW NOTE FLOW (FIXED)
      -- =========================
      {
        "<leader>on",
        function()
          local Obsidian = require("obsidian")

          local vault_path = vim.fn.expand("~/Exocortex")
          local notes_dir = vault_path .. "/limbus"
          local template_dir = vault_path .. "/templates"

          -- local ID generator (no Obsidian.opts dependency)
          local function note_id_func(title)
            local suffix = ""

            if title and title ~= "" then
              suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
            else
              suffix = tostring(math.random(1000, 9999))
            end

            return tostring(os.time()) .. "-" .. suffix
          end

          vim.ui.select({ "Default (Zettelkasten)", "Template" }, {
            prompt = "¿Cómo quieres crear la nota?",
          }, function(choice)
            if not choice then
              return
            end

            local title = vim.fn.input("Note title: ")
            if not title or title == "" then
              return
            end

            local note_id = note_id_func(title)

            -- =========================
            -- TEMPLATE MODE
            -- =========================
            if choice == "Template" then
              local scan = require("plenary.scandir")

              local templates = scan.scan_dir(template_dir, {
                depth = 1,
                add_dirs = false,
              })

              if not templates or vim.tbl_isempty(templates) then
                vim.notify("No templates found in " .. template_dir, vim.log.levels.ERROR)
                return
              end

              local template_names = {}
              local template_map = {}

              for _, path in ipairs(templates) do
                local name = vim.fn.fnamemodify(path, ":t")
                template_names[#template_names + 1] = name
                template_map[name] = path
              end

              vim.ui.select(template_names, {
                prompt = "Selecciona template",
              }, function(selected_template)
                if not selected_template then
                  return
                end

                local note_path = notes_dir .. "/" .. note_id .. ".md"
                local template_path = template_map[selected_template]

                -- 🔥 FIX: actually load template file
                local content = table.concat(vim.fn.readfile(template_path), "\n")

                -- 🔧 template engine
                content = content:gsub("{%s*{%s*id%s*}%s*}", note_id)
                content = content:gsub("{%s*{%s*title%s*}%s*}", title)
                content = content:gsub("{%s*{%s*date%s*}%s*}", os.date("%Y-%m-%d"))

                local file = io.open(note_path, "w")
                if not file then
                  vim.notify("Error creando nota", vim.log.levels.ERROR)
                  return
                end

                file:write(content)
                file:close()

                vim.cmd("edit " .. note_path)
                vim.notify("✓ Created from template: " .. selected_template)
              end)

            -- =========================
            -- MANUAL MODE (ZETTELKASTEN)
            -- =========================
            else
              local note_path = notes_dir .. "/" .. note_id .. ".md"

              local yaml = {
                "---",
                "id: " .. note_id,
                "aliases:",
                "  - " .. title,
                "tags:",
                "---",
                "",
                "# " .. title,
                "",
              }

              local file = io.open(note_path, "w")
              if file then
                file:write(table.concat(yaml, "\n"))
                file:close()
                vim.cmd("edit " .. note_path)
                vim.notify("✓ Zettelkasten note created")
              else
                vim.notify("Error creando nota", vim.log.levels.ERROR)
              end
            end
          end)
        end,
        desc = "Obsidian New Note (template aware)",
      },

      -- =========================
      -- MOVE NOTE
      -- =========================
      {
        "<leader>om",
        function()
          local Obsidian = require("obsidian")
          local api = Obsidian.api

          local note = api.current_note()
          if not note or not note.path then
            vim.notify("No active Obsidian note", vim.log.levels.ERROR)
            return
          end

          local vault_path = note.path:parent():parent()
          local scan = require("plenary.scandir")

          local existing_folders = {}

          local subdirs = scan.scan_dir(tostring(vault_path), {
            only_dirs = true,
            depth = 2,
          })

          for _, subdir in ipairs(subdirs) do
            local relative = subdir:gsub(tostring(vault_path) .. "/", "")
            table.insert(existing_folders, relative)
          end

          table.sort(existing_folders)

          local options = vim.deepcopy(existing_folders)
          table.insert(options, "  Create new folder...")

          vim.ui.select(options, {
            prompt = "Move note to:",
          }, function(choice)
            if not choice then
              return
            end

            local function move_note(target_folder)
              local new_dir = tostring(vault_path) .. "/" .. target_folder
              vim.fn.mkdir(new_dir, "p")

              local old_path = tostring(note.path)
              local fname = vim.fn.fnamemodify(old_path, ":t")
              local new_path = new_dir .. "/" .. fname

              vim.loop.fs_rename(old_path, new_path)
              vim.cmd("bdelete")
              vim.cmd("edit " .. new_path)

              vim.notify("✓ Moved to " .. target_folder)
            end

            if choice == "  Create new folder..." then
              vim.ui.input({
                prompt = "New folder path:",
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

      -- =========================
      -- TODO → ZETTELKASTEN NOTE + LINK
      -- =========================
      {
        "<leader>oc",
        function()
          local line = vim.api.nvim_get_current_line()
          local todo_text = line:match("^%- %[ %] #TODO:%s*(.+)$")

          if not todo_text or todo_text == "" then
            vim.notify("No #TODO: found on current line", vim.log.levels.WARN)
            return
          end

          local title = vim.trim(todo_text)
          local vault_path = vim.fn.expand("~/Exocortex")
          local notes_dir = vault_path .. "/limbus"
          local template_dir = vault_path .. "/templates"

          -- same ID strategy as <leader>on Zettelkasten mode
          local suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
          local note_id = tostring(os.time()) .. "-" .. suffix

          local note_path = notes_dir .. "/" .. note_id .. ".md"

          vim.ui.select({ "Default (Zettelkasten)", "Template" }, {
            prompt = "¿Cómo quieres crear la nota?",
          }, function(choice)
            if not choice then
              return
            end

            local function finalize()
              -- replace the TODO line with a checkbox + wikilink
              local link = "[[" .. note_id .. "|" .. title .. "]]"
              vim.api.nvim_set_current_line("- [ ] " .. link)
              vim.notify("✓ Note created from TODO: " .. title)
            end

            -- =========================
            -- TEMPLATE MODE
            -- =========================
            if choice == "Template" then
              local scan = require("plenary.scandir")

              local templates = scan.scan_dir(template_dir, {
                depth = 1,
                add_dirs = false,
              })

              if not templates or vim.tbl_isempty(templates) then
                vim.notify("No templates found in " .. template_dir, vim.log.levels.ERROR)
                return
              end

              local template_names = {}
              local template_map = {}

              for _, path in ipairs(templates) do
                local name = vim.fn.fnamemodify(path, ":t")
                template_names[#template_names + 1] = name
                template_map[name] = path
              end

              vim.ui.select(template_names, {
                prompt = "Selecciona template",
              }, function(selected_template)
                if not selected_template then
                  return
                end

                local template_path = template_map[selected_template]

                -- load template file
                local content = table.concat(vim.fn.readfile(template_path), "\n")

                -- template engine
                content = content:gsub("{%s*{%s*id%s*}%s*}", note_id)
                content = content:gsub("{%s*{%s*title%s*}%s*}", title)
                content = content:gsub("{%s*{%s*date%s*}%s*}", os.date("%Y-%m-%d"))

                local file = io.open(note_path, "w")
                if not file then
                  vim.notify("Error creating note", vim.log.levels.ERROR)
                  return
                end

                file:write(content)
                file:close()

                vim.cmd("edit " .. note_path)
                finalize()
              end)

            -- =========================
            -- DEFAULT MODE (ZETTELKASTEN)
            -- =========================
            else
              local yaml = {
                "---",
                "id: " .. note_id,
                "aliases:",
                "  - " .. title,
                "tags:",
                "---",
                "",
                "# " .. title,
                "",
              }

              local file = io.open(note_path, "w")
              if not file then
                vim.notify("Error creating note", vim.log.levels.ERROR)
                return
              end

              file:write(table.concat(yaml, "\n"))
              file:close()

              vim.cmd("edit " .. note_path)
              finalize()
            end
          end)
        end,
        desc = "Obsidian TODO → Zettelkasten note + link",
        ft = "markdown",
      },

      -- =========================
      -- TODO TOGGLE
      -- =========================
      {
        "<leader>ot",
        function()
          local line = vim.api.nvim_get_current_line()

          if line:match("^%- %[ %] #TODO:") then
            vim.api.nvim_set_current_line(line:gsub("^%- %[ %] #TODO:", "- [ ]", 1))
          elseif line:match("^%- %[ %]") then
            vim.api.nvim_set_current_line(line:gsub("^%- %[ %]", "- [ ] #TODO:", 1))
          else
            vim.api.nvim_set_current_line("- [ ] #TODO: " .. line)
          end
        end,
        desc = "Toggle TODO checkbox",
        ft = "markdown",
      },
    },

    event = {
      "BufReadPre " .. vim.fn.expand("~") .. "/Exocortex/**.md",
      "BufNewFile " .. vim.fn.expand("~") .. "/Exocortex/**.md",
    },

    dependencies = {
      "nvim-lua/plenary.nvim",
      "saghen/blink.cmp",
    },

    opts = {
      legacy_commands = false,

      workspaces = {
        {
          name = "Exocortex",
          path = "~/Exocortex",
        },
      },

      ui = {
        enable = false,
      },

      checkbox = {
        enable = true,
        create_new = true,
        order = { " ", "x", "!", ">", "~" },
      },

      notes_subdir = "limbus",
      new_notes_location = "limbus",

      attachments = {
        folder = "files",
      },

      daily_notes = {
        template = "note",
      },

      frontmatter = {
        func = function(note)
          local out = {
            id = note.id,
            aliases = note.aliases,
            tags = note.tags,
          }

          if note.metadata and not vim.tbl_isempty(note.metadata) then
            for k, v in pairs(note.metadata) do
              out[k] = v
            end
          end

          return out
        end,
      },

      templates = {
        subdir = "templates",
        date_format = "%Y-%m-%d-%a",
        gtime_format = "%H:%M",
        tags = "",
      },
    },
  },
}
