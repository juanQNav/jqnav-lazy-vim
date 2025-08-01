-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Autocomando para archivos Markdown
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.textwidth = 80
    vim.opt_local.formatoptions = "tcroqln"
    vim.opt_local.wrapmargin = 0
  end,
})

-- Función para formatear líneas largas manualmente
local function format_long_lines()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local new_lines = {}

  for _, line in ipairs(lines) do
    -- Skip code blocks, headers, and lists (but not bold text)
    if line:match("^```") or line:match("^#+%s") or line:match("^%s*[*+-]%s") or line:match("^%s*%d+%.%s") then
      table.insert(new_lines, line)
    elseif #line > 80 then
      -- Mejorado: dividir líneas largas respetando espacios y formato
      local remaining = line

      while #remaining > 80 do
        local cut_pos = 80
        -- Buscar el último espacio antes del límite de 80 caracteres
        for i = 80, 1, -1 do
          if remaining:sub(i, i) == " " then
            cut_pos = i - 1
            break
          end
        end

        -- Si no encontramos espacio, cortar en 80
        if cut_pos == 80 and remaining:sub(80, 80) ~= " " then
          cut_pos = 79
        end

        local current_part = remaining:sub(1, cut_pos)
        table.insert(new_lines, current_part)

        -- Preparar el resto de la línea, eliminando espacios al inicio
        remaining = remaining:sub(cut_pos + 1):gsub("^%s+", "")
      end

      -- Agregar lo que queda si no está vacío
      if remaining:gsub("^%s+", "") ~= "" then
        table.insert(new_lines, remaining)
      end
    else
      table.insert(new_lines, line)
    end
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
end

-- Autoformatear al guardar
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.md",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    format_long_lines()
    vim.fn.setpos(".", save_cursor)
  end,
})
