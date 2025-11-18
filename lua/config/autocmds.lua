-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Autocommand for Markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.textwidth = 80
    vim.opt_local.formatoptions = "tcroqln"
    vim.opt_local.wrapmargin = 0
  end,
})

local function format_long_lines()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local new_lines = {}
  local in_table = false
  local skip_format = false
  local in_code_block = false -- State for code blocks

  for _, line in ipairs(lines) do
    -- Detect format control tags
    if line:match("<!--%s*format:off%s*-->") then
      skip_format = true
      table.insert(new_lines, line)
    elseif line:match("<!--%s*format:on%s*-->") then
      skip_format = false
      table.insert(new_lines, line)
    elseif skip_format then
      -- Inside a format:off block → do not format
      table.insert(new_lines, line)
    else
      -- Detect code fences
      if line:match("^```") then
        in_code_block = not in_code_block
        table.insert(new_lines, line)
      elseif in_code_block then
        -- Inside code block → do not format
        table.insert(new_lines, line)
      else
        -- Detect if we are inside a Markdown table
        if line:match("^%s*|") then
          in_table = true
        elseif in_table and line:match("^%s*$") then
          in_table = false
        end

        -- Skip special blocks: headings, tables, links
        if
          line:match("^#+%s")
          or in_table
          or line:match("%b[]%b()") -- Lines with Markdown links
        then
          table.insert(new_lines, line)

        -- Handle unordered lists (preserve bullet and indent)
        elseif line:match("^%s*[*+-]%s") then
          local indent, bullet, content = line:match("^(%s*)([%*%-+])%s(.+)$")
          if content then
            local remaining = content
            local max_width = 80 - #indent - 2
            while #remaining > max_width do
              local cut_pos = max_width
              for i = max_width, 1, -1 do
                if remaining:sub(i, i) == " " then
                  cut_pos = i
                  break
                end
              end
              table.insert(new_lines, indent .. bullet .. " " .. remaining:sub(1, cut_pos))
              remaining = remaining:sub(cut_pos + 1):gsub("^%s+", "")
            end
            if remaining ~= "" then
              table.insert(new_lines, indent .. bullet .. " " .. remaining)
            end
          else
            table.insert(new_lines, line)
          end

        -- Handle ordered lists (numbers)
        elseif line:match("^%s*%d+%.%s") then
          local indent, num, content = line:match("^(%s*)(%d+%.%s)(.+)$")
          if content then
            local remaining = content
            local max_width = 80 - #indent - #num
            while #remaining > max_width do
              local cut_pos = max_width
              for i = max_width, 1, -1 do
                if remaining:sub(i, i) == " " then
                  cut_pos = i
                  break
                end
              end
              table.insert(new_lines, indent .. num .. remaining:sub(1, cut_pos))
              remaining = remaining:sub(cut_pos + 1):gsub("^%s+", "")
            end
            if remaining ~= "" then
              table.insert(new_lines, indent .. num .. remaining)
            end
          else
            table.insert(new_lines, line)
          end

        -- Handle normal long lines
        elseif #line > 80 then
          local remaining = line
          while #remaining > 80 do
            local cut_pos = 80
            for i = 80, 1, -1 do
              if remaining:sub(i, i) == " " then
                cut_pos = i - 1
                break
              end
            end
            if cut_pos == 80 and remaining:sub(80, 80) ~= " " then
              cut_pos = 79
            end
            local current_part = remaining:sub(1, cut_pos)
            table.insert(new_lines, current_part)
            remaining = remaining:sub(cut_pos + 1):gsub("^%s+", "")
          end
          if remaining:gsub("^%s+", "") ~= "" then
            table.insert(new_lines, remaining)
          end
        else
          table.insert(new_lines, line)
        end
      end
    end
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
end

-- Autoformat on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.md",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    format_long_lines()
    vim.fn.setpos(".", save_cursor)
  end,
})
