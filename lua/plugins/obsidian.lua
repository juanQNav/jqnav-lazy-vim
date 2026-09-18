-- This file contains the configuration for the obsidian.nvim plugin in Neovim.

-- =========================
-- VAULT REGISTRY (JSON-BASED)
-- =========================
local VAULT_REGISTRY_PATH = vim.fn.stdpath("config") .. "/data/obsidian/vaults.json"

-- Read vaults from JSON registry
local function read_vault_registry()
  local ok, content = pcall(vim.fn.readfile, VAULT_REGISTRY_PATH)
  if not ok then
    return {}
  end

  local ok_json, parsed = pcall(vim.json.decode, table.concat(content, "\n"))
  if not ok_json then
    vim.notify("[obsidian] Corrupted vaults.json, starting empty", vim.log.levels.WARN)
    return {}
  end

  -- Validate each entry and preserve optional vault-specific settings
  local vaults = {}
  for _, v in ipairs(parsed or {}) do
    if v.name and v.path then
      local entry = { name = v.name, path = vim.fn.expand(v.path) }
      if v.notes_subdir then entry.notes_subdir = v.notes_subdir end
      if v.templates_subdir then entry.templates_subdir = v.templates_subdir end
      if v.id_strategy then entry.id_strategy = v.id_strategy end
      table.insert(vaults, entry)
    end
  end

  return vaults
end

-- Write vaults to JSON registry
local function write_vault_registry(vaults)
  local out = {}
  for _, v in ipairs(vaults) do
    table.insert(out, { name = v.name, path = v.path })
  end

  local ok_json, json_str = pcall(vim.json.encode, out)
  if not ok_json then
    vim.notify("[obsidian] Failed to serialize vault registry", vim.log.levels.ERROR)
    return
  end

  -- Atomic write: write to tmp then rename
  local tmp = VAULT_REGISTRY_PATH .. ".tmp"
  local file = io.open(tmp, "w")
  if not file then
    vim.notify("[obsidian] Cannot write vault registry", vim.log.levels.ERROR)
    return
  end

  file:write(json_str)
  file:close()

  -- Pretty-print with jq if available
  local formatted = vim.fn.system("jq '.' " .. vim.fn.shellescape(tmp))
  if vim.v.shell_error == 0 then
    local f = io.open(tmp, "w")
    if f then
      f:write(formatted)
      f:close()
    end
  end

  vim.loop.fs_rename(tmp, VAULT_REGISTRY_PATH)
end

-- =========================
-- VAULT CREATION COMMAND
-- =========================
local function register_new_vault()
  vim.ui.input({ prompt = "Vault name:" }, function(name)
    if not name or vim.trim(name) == "" then
      return
    end

    name = vim.trim(name)

    -- Check for duplicate
    local vaults = read_vault_registry()
    for _, v in ipairs(vaults) do
      if v.name == name then
        vim.notify("[obsidian] Vault '" .. name .. "' already exists", vim.log.levels.WARN)
        return
      end
    end

    vim.ui.input({
      prompt = "Vault path:",
      default = "~/" .. name,
      completion = "dir",
    }, function(path)
      if not path or vim.trim(path) == "" then
        return
      end

      path = vim.fn.expand(vim.trim(path))

      -- Check if path is already registered by another name
      for _, v in ipairs(vaults) do
        if v.path == path then
          vim.notify("[obsidian] Path '" .. path .. "' already registered as '" .. v.name .. "'", vim.log.levels.WARN)
          return
        end
      end

      -- Check if path already exists on disk
      local dir_exists = vim.fn.isdirectory(path) == 1
      if dir_exists then
        local has_obsidian = vim.fn.isdirectory(path .. "/.obsidian") == 1
        if not has_obsidian then
          vim.notify("[obsidian] Directory '" .. path .. "' exists but is not an Obsidian vault. Pick an empty or non-existent path to create a new one.", vim.log.levels.ERROR)
          return
        end
        -- Existing Obsidian vault — adopt it
        vim.notify("[obsidian] Adopting existing vault at " .. path, vim.log.levels.INFO)
      else
        -- Create folder structure
        local obsidian_dir = path .. "/.obsidian"
        local ok = pcall(vim.fn.mkdir, path, "p")
        if not ok then
          vim.notify("[obsidian] Cannot create directory: " .. path, vim.log.levels.ERROR)
          return
        end

        ok = pcall(vim.fn.mkdir, obsidian_dir)
        if not ok then
          vim.notify("[obsidian] Cannot create .obsidian directory", vim.log.levels.WARN)
        end
      end

      -- Register in JSON
      table.insert(vaults, { name = name, path = path })
      write_vault_registry(vaults)

      if dir_exists then
        vim.notify("[obsidian] Vault '" .. name .. "' registered at " .. path)
      else
        vim.notify("[obsidian] Vault '" .. name .. "' created at " .. path)
      end
    end)
  end)
end

-- Register command
vim.api.nvim_create_user_command("ObsidianVaultAdd", register_new_vault, { nargs = 0 })

-- =========================
-- VAULT REMOVAL COMMAND
-- =========================
local function unregister_vault()
  local vaults = read_vault_registry()

  if vim.tbl_isempty(vaults) then
    vim.notify("[obsidian] No registered vaults to remove", vim.log.levels.WARN)
    return
  end

  local labels = {}
  for _, v in ipairs(vaults) do
    table.insert(labels, v.name .. "  (" .. v.path .. ")")
  end

  vim.ui.select(labels, {
    prompt = "Remove vault (folder will NOT be deleted):",
  }, function(choice)
    if not choice then
      return
    end

    -- Find matching vault index
    for i, label in ipairs(labels) do
      if label == choice then
        local removed = vaults[i]
        table.remove(vaults, i)
        write_vault_registry(vaults)
        vim.notify("[obsidian] Vault '" .. removed.name .. "' removed from registry")
        return
      end
    end
  end)
end

vim.api.nvim_create_user_command("ObsidianVaultRemove", unregister_vault, { nargs = 0 })

-- =========================
-- VAULT EDIT COMMAND
-- =========================
local function edit_vault()
  local vaults = read_vault_registry()

  if vim.tbl_isempty(vaults) then
    vim.notify("[obsidian] No registered vaults to edit", vim.log.levels.WARN)
    return
  end

  local labels = {}
  for _, v in ipairs(vaults) do
    table.insert(labels, v.name .. "  (" .. v.path .. ")")
  end

  vim.ui.select(labels, {
    prompt = "Edit vault settings:",
  }, function(choice)
    if not choice then
      return
    end

    local idx = nil
    for i, label in ipairs(labels) do
      if label == choice then
        idx = i
        break
      end
    end
    if not idx then return end

    local v = vaults[idx]

    -- Show current values
    local current_notes = v.notes_subdir or "limbus"
    local current_templates = v.templates_subdir or "templates"
    local current_id = v.id_strategy or "zettel"

    vim.notify(
      "Current: notes=" .. current_notes .. " | templates=" .. current_templates .. " | id=" .. current_id,
      vim.log.levels.INFO
    )

    -- Ask for notes_subdir
    vim.ui.input({
      prompt = "Notes subdir (current: " .. current_notes .. "):",
      default = current_notes,
    }, function(notes_subdir)
      if not notes_subdir then return end
      v.notes_subdir = notes_subdir ~= "limbus" and notes_subdir or nil

      -- Ask for templates_subdir
      vim.ui.input({
        prompt = "Templates subdir (current: " .. current_templates .. "):",
        default = current_templates,
      }, function(templates_subdir)
        if not templates_subdir then return end
        v.templates_subdir = templates_subdir ~= "templates" and templates_subdir or nil

        -- Ask for id_strategy
        vim.ui.select({ "zettel (timestamp-slug)", "slug (slug only)" }, {
          prompt = "ID strategy:",
          default = current_id == "zettel" and 1 or 2,
        }, function(id_choice)
          if not id_choice then return end
          local strategy = id_choice == "zettel (timestamp-slug)" and "zettel" or "slug"
          v.id_strategy = strategy ~= "zettel" and strategy or nil

          write_vault_registry(vaults)
          vim.notify(
            "[obsidian] Vault '" .. v.name .. "' updated: notes="
              .. (v.notes_subdir or "limbus")
              .. " | templates="
              .. (v.templates_subdir or "templates")
              .. " | id="
              .. (v.id_strategy or "zettel"),
            vim.log.levels.INFO
          )
        end)
      end)
    end)
  end)
end

vim.api.nvim_create_user_command("ObsidianVaultEdit", edit_vault, { nargs = 0 })

-- Generate lazy-load events for all registered vaults
local function vault_events()
  local events = {}
  local vaults = read_vault_registry()
  for _, ws in ipairs(vaults) do
    table.insert(events, "BufReadPre " .. ws.path .. "/**.md")
    table.insert(events, "BufNewFile " .. ws.path .. "/**.md")
  end
  return #events > 0 and events or { "BufReadPre *.md", "BufNewFile *.md" }
end

-- Resolve vault context from buffer path or obsidian client
local function resolve_vault_context()
  local buf_path = vim.api.nvim_buf_get_name(0)
  local vaults = read_vault_registry()

  -- Strategy 1: match current buffer against known vaults
  if buf_path ~= "" then
    for _, ws in ipairs(vaults) do
      if buf_path:sub(1, #ws.path) == ws.path then
        local notes_subdir = ws.notes_subdir or "limbus"
        local templates_subdir = ws.templates_subdir or "templates"
        local id_strategy = ws.id_strategy or "zettel"
        return {
          vault_path = ws.path,
          notes_dir = ws.path .. "/" .. notes_subdir,
          template_dir = ws.path .. "/" .. templates_subdir,
          id_strategy = id_strategy,
        }
      end
    end
  end

  -- Strategy 2: try obsidian.nvim client for active workspace
  local ok, obsidian = pcall(require, "obsidian")
  if ok then
    local client = obsidian.get_client()
    if client and client["dir"] then
      local vault_path = tostring(client["dir"])
      return {
        vault_path = vault_path,
        notes_dir = vault_path .. "/limbus",
        template_dir = vault_path .. "/templates",
        id_strategy = "zettel",
      }
    end
  end

  -- Fallback: first registered vault
  local ws = vaults[1]
  local notes_subdir = ws.notes_subdir or "limbus"
  local templates_subdir = ws.templates_subdir or "templates"
  local id_strategy = ws.id_strategy or "zettel"
  return {
    vault_path = ws.path,
    notes_dir = ws.path .. "/" .. notes_subdir,
    template_dir = ws.path .. "/" .. templates_subdir,
    id_strategy = id_strategy,
  }
end

-- Shared ID generator with strategy support
local function generate_note_id(title, strategy)
  local suffix = ""
  if title and title ~= "" then
    suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
  else
    suffix = tostring(math.random(1000, 9999))
  end

  if strategy == "slug" then
    return suffix
  end
  -- default: zettel (timestamp + slug)
  return tostring(os.time()) .. "-" .. suffix
end

-- Legacy wrapper for obsidian.nvim opts
local function note_id_func(title)
  return generate_note_id(title, "zettel")
end

return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    cmd = { "Obsidian" },

    event = vault_events(),

    keys = {
      { "<leader>oo", "<cmd>Obsidian quick_switch<cr>", desc = "Obsidian Quick Switch" },
      { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Obsidian Search" },
      { "<leader>oa", "<cmd>Obsidian open<cr>", desc = "Obsidian Open Vault" },
      { "<leader>ov", "<cmd>ObsidianVaultAdd<cr>", desc = "Obsidian Add Vault" },
      { "<leader>oe", "<cmd>ObsidianVaultEdit<cr>", desc = "Obsidian Edit Vault" },
      { "<leader>oD", "<cmd>ObsidianVaultRemove<cr>", desc = "Obsidian Remove Vault" },
      { "<leader>of", "<cmd>Obsidian follow_link<cr>", desc = "Obsidian Follow Link", ft = "markdown" },
      { "<leader>od", "<cmd>Obsidian toggle_checkbox<cr>", desc = "Obsidian Toggle Checkbox", ft = "markdown" },

      -- =========================
      -- NEW NOTE FLOW (VAULT-AGNOSTIC, ID-STRATEGY AWARE)
      -- =========================
      {
        "<leader>on",
        function()
          local ctx = resolve_vault_context()

          vim.ui.select({ "Con timestamp (zettelkasten)", "Sin timestamp (slug)", "Desde template" }, {
            prompt = "¿Cómo quieres crear la nota?",
          }, function(choice)
            if not choice then
              return
            end

            local title = vim.fn.input("Note title: ")
            if not title or title == "" then
              return
            end

            local id_strategy = choice == "Sin timestamp (slug)" and "slug" or "zettel"
            local note_id = generate_note_id(title, id_strategy)

            -- =========================
            -- TEMPLATE MODE
            -- =========================
            if choice == "Desde template" then
              local scan = require("plenary.scandir")

              local templates = scan.scan_dir(ctx.template_dir, {
                depth = 2,
                add_dirs = false,
              })

              if not templates or vim.tbl_isempty(templates) then
                vim.notify("No templates found in " .. ctx.template_dir, vim.log.levels.ERROR)
                return
              end

              local template_names = {}
              local template_map = {}

              for _, path in ipairs(templates) do
                local name = path:gsub(vim.pesc(ctx.template_dir) .. "/", "")
                template_names[#template_names + 1] = name
                template_map[name] = path
              end

              vim.ui.select(template_names, {
                prompt = "Selecciona template",
              }, function(selected_template)
                if not selected_template then
                  return
                end

                local note_path = ctx.notes_dir .. "/" .. note_id .. ".md"
                local template_path = template_map[selected_template]

                local content = table.concat(vim.fn.readfile(template_path), "\n")

                -- Template engine
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
            -- MANUAL MODE
            -- =========================
            else
              local note_path = ctx.notes_dir .. "/" .. note_id .. ".md"

              local yaml
              if id_strategy == "slug" then
                yaml = {
                  "---",
                  "aliases:",
                  "  - " .. title,
                  "tags:",
                  "---",
                  "",
                  "# " .. title,
                  "",
                }
              else
                yaml = {
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
              end

              local file = io.open(note_path, "w")
              if file then
                file:write(table.concat(yaml, "\n"))
                file:close()
                vim.cmd("edit " .. note_path)
                vim.notify("✓ Note created: " .. note_id)
              else
                vim.notify("Error creando nota", vim.log.levels.ERROR)
              end
            end
          end)
        end,
        desc = "Obsidian New Note (vault-aware, id-strategy aware)",
      },

      -- =========================
      -- MOVE NOTE (VAULT-AGNOSTIC)
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
      -- COPY FOLDER OUTSIDE VAULT (VAULT-AGNOSTIC)
      -- =========================
      {
        "<leader>oC",
        function()
          local current_file = vim.api.nvim_buf_get_name(0)
          if current_file == "" then
            vim.notify("No file open", vim.log.levels.ERROR)
            return
          end

          local src_dir = vim.fn.fnamemodify(current_file, ":h")
          local folder_name = vim.fn.fnamemodify(src_dir, ":t")

          -- Find which vault this file belongs to
          local vault_path = nil
          local vaults = read_vault_registry()
          for _, ws in ipairs(vaults) do
            if src_dir:sub(1, #ws.path) == ws.path then
              vault_path = ws.path:gsub("/+$", "")
              break
            end
          end

          if not vault_path then
            vim.notify("Current file is not inside a known vault", vim.log.levels.ERROR)
            return
          end

          vim.ui.input({
            prompt = "Copy TO (absolute path):",
            default = "~/",
          }, function(dst)
            if not dst or dst == "" then
              return
            end

            dst = vim.fn.expand(dst):gsub("/+$", "")

            if dst == vault_path or dst:sub(1, #vault_path + 1) == vault_path .. "/" then
              vim.notify("Destination must be outside the vault", vim.log.levels.ERROR)
              return
            end

            local cmd = string.format("cp -r %s %s", vim.fn.shellescape(src_dir), vim.fn.shellescape(dst))
            local result = vim.fn.system(cmd)
            local exit_code = vim.v.shell_error

            if exit_code == 0 then
              vim.notify("✓ Copied to " .. dst .. "/" .. folder_name)
            else
              vim.notify("✗ Copy failed: " .. result, vim.log.levels.ERROR)
            end
          end)
        end,
        desc = "Obsidian Copy Folder Outside Vault",
        ft = "markdown",
      },

      -- =========================
      -- TODO → NOTE + LINK (VAULT-AGNOSTIC, ID-STRATEGY AWARE)
      -- =========================
      {
        "<leader>oc",
        function()
          local line = vim.api.nvim_get_current_line()
          local todo_text = line:match("^%- %[ %] #TODO:%s*([^.]*)")
          local rest_text = line:match("^%- %[ %] #TODO:%s*[^.]*([.].*)$")

          if not todo_text or todo_text == "" then
            vim.notify("No #TODO: found on current line", vim.log.levels.WARN)
            return
          end

          local ctx = resolve_vault_context()
          local title = vim.trim(todo_text)

          -- Ask for ID strategy first
          vim.ui.select({ "Con timestamp (zettelkasten)", "Sin timestamp (slug)", "Desde template" }, {
            prompt = "¿Cómo quieres crear la nota?",
          }, function(choice)
            if not choice then
              return
            end

            local id_strategy = choice == "Sin timestamp (slug)" and "slug" or "zettel"
            local note_id = generate_note_id(title, id_strategy)
            local note_path = ctx.notes_dir .. "/" .. note_id .. ".md"

            local function create_wikilink()
              -- Replace the TODO line with a checkbox + wikilink
              local link = "[[" .. note_id .. "|" .. title .. "]]"
              vim.api.nvim_set_current_line("- [ ] #TODO:" .. link .. rest_text)
              vim.notify("✓ Note created from TODO: " .. title)
            end

            -- =========================
            -- TEMPLATE MODE
            -- =========================
            if choice == "Desde template" then
              create_wikilink()
              local scan = require("plenary.scandir")

              local templates = scan.scan_dir(ctx.template_dir, {
                depth = 2,
                add_dirs = false,
              })

              if not templates or vim.tbl_isempty(templates) then
                vim.notify("No templates found in " .. ctx.template_dir, vim.log.levels.ERROR)
                return
              end

              local template_names = {}
              local template_map = {}

              for _, path in ipairs(templates) do
                local name = path:gsub(vim.pesc(ctx.template_dir) .. "/", "")
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

                -- Load template file
                local content = table.concat(vim.fn.readfile(template_path), "\n")

                -- Template engine
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
              end)

            -- =========================
            -- DEFAULT MODE
            -- =========================
            else
              create_wikilink()
              local yaml
              if id_strategy == "slug" then
                yaml = {
                  "---",
                  "aliases:",
                  "  - " .. title,
                  "tags:",
                  "---",
                  "",
                  "# " .. title,
                  "",
                }
              else
                yaml = {
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
              end

              local file = io.open(note_path, "w")
              if not file then
                vim.notify("Error creating note", vim.log.levels.ERROR)
                return
              end

              file:write(table.concat(yaml, "\n"))
              file:close()

              vim.cmd("edit " .. note_path)
            end
          end)
        end,
        desc = "Obsidian TODO → note + link (vault-aware, id-strategy aware)",
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

    dependencies = {
      "nvim-lua/plenary.nvim",
      "saghen/blink.cmp",
    },

    opts = {
      legacy_commands = false,

      workspaces = read_vault_registry(),

      ui = {
        enable = false,
      },

      checkbox = {
        enable = true,
        create_new = true,
        order = { " ", "x", "!", ">", "~" },
      },

      attachments = {
        folder = "files",
      },

      daily_notes = {
        template = "note",
      },

      -- CRITICAL: This is used by blink.cmp/obsidian.nvim completion
      -- when creating notes from [[wikilinks]]. Without this, the plugin
      -- uses its default ID generator which produces garbage like "MEDA".
      note_id_func = note_id_func,

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
