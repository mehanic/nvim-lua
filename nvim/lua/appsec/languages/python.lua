local utils = require("appsec.utils")

local M = {}

--- Список функцій/класів з метриками для Python
---@return fun(): string
function M.list_functions_step()
  return function()
    -- 1. Пробуємо отримати поточний файл
    local current_filepath = vim.fn.expand("%:p")
    local current_filename = vim.fn.fnamemodify(current_filepath, ":t")

    -- 2. Якщо це не .py або файл не читається, шукаємо серед відкритих буферів
    if not current_filename:match("%.py$") or vim.fn.filereadable(current_filepath) ~= 1 then
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          if bufname:match("%.py$") and vim.fn.filereadable(bufname) == 1 then
            current_filepath = bufname
            current_filename = vim.fn.fnamemodify(current_filepath, ":t")
            break
          end
        end
      end
    end

    -- 3. Фінальна перевірка
    if current_filename == "" or not current_filename:match("%.py$") then
      return "ℹ️ No Python file detected. Open a .py file first."
    end
    if vim.fn.filereadable(current_filepath) ~= 1 then
      return string.format("ℹ️ Cannot read: %s", current_filename)
    end

    -- Крок 1: Надійний Lua-парсер
    local file_lines = vim.fn.readfile(current_filepath)
    if not file_lines or #file_lines == 0 then
      return string.format("ℹ️ Empty or unreadable: %s", current_filename)
    end

    local funcs = {}
    local name_pat = "[%a_][%w_]*"
    for i, line in ipairs(file_lines) do
      line = line:gsub("\r", "")
      local kind, n

      n = line:match("^%s*class%s+(" .. name_pat .. ")")
      if n then
        kind = "class"
      else
        n = line:match("^%s*async%s+def%s+(" .. name_pat .. ")%s*%(")
        if n then
          kind = "async def"
        else
          n = line:match("^%s*def%s+(" .. name_pat .. ")%s*%(")
          if n then
            kind = "def"
          end
        end
      end

      if n then
        table.insert(funcs, { name = n, line = i, kind = kind })
      end
    end

    if #funcs == 0 then
      return string.format("ℹ️ No functions/classes found in %s", current_filename)
    end

    -- Крок 2: Складність (radon cc)
    local complexity_data = {}
    if vim.fn.executable("radon") == 1 then
      local rad_out = vim.fn.system(string.format("radon cc -s -a '%s' 2>/dev/null", current_filepath))
      for rad_line in rad_out:gmatch("[^\r\n]+") do
        local n, c = rad_line:match("([%w_]+)%s*%-%s*%w+%s*%((%d+)%)")
        if n and c then
          complexity_data[n] = tonumber(c)
        end
      end
    end

    for _, f in ipairs(funcs) do
      local start_line = f.line
      local end_line = #file_lines

      for i = start_line + 1, #file_lines do
        local next_line = file_lines[i]
        if
          next_line:match("^%s*class%s+")
          or next_line:match("^%s*def%s+")
          or next_line:match("^%s*async%s+def%s+")
        then
          end_line = i - 1
          break
        end
      end

      local loc = end_line - start_line + 1
      local cyc = complexity_data[f.name]
      local body = table.concat(utils.slice(file_lines, start_line, end_line), "\n")

      -- 🔹 Big O естимація
      local big_o = "O(1)"
      local has_for = body:match("for%s+.*in%s+") ~= nil
      local has_while = body:match("while%s+") ~= nil

      if has_for or has_while then
        if
          body:match("for%s+.*in%s+.*for%s+.*in%s+")
          or body:match("while%s+.*while%s+")
          or (has_for and has_while)
        then
          big_o = "O(n²)"
        else
          big_o = "O(n)"
        end
      elseif body:match(f.name .. "%s*%(") then
        big_o = "O(log n)"
      end

      -- 🔹 Resource hints
      local resources = "🟢 Low"
      if body:match("list%s*%(") or body:match("dict%s*%(") or body:match("set%s*%(") or body:match("%[%s*%]") then
        resources = "🟡 Med"
      end
      if body:match("%.append%s*%(") or body:match("%.extend%s*%(") or body:match("import%s+threading") then
        resources = resources == "🟢 Low" and "🟡 Med" or "🔴 High"
      end
      if
        body:match("async%s+def")
        or body:match("asyncio%s*%.")
        or body:match("multiprocessing")
        or body:match("ThreadPoolExecutor")
      then
        resources = "🔴 High"
      end
      if cyc and cyc >= 20 then
        resources = "🔴 High"
      elseif cyc and cyc >= 10 then
        resources = resources == "🟢 Low" and "🟡 Med" or resources
      end

      f.loc = loc
      f.cyc = cyc
      f.big_o = big_o
      f.resources = resources
    end

    -- Крок 4: Форматуємо таблицю
    local table_lines = {
      string.format("🐍 Python Functions in %s (%d total):", current_filename, #funcs),
      "┌─┬─────────────────┬────────────┬───────────┬───────┬────────────┐",
      "│#│ Function/Class  │ Location   │ Complexity│ Big O │ Resources  │",
      "├─┼─────────────────┼────────────┼───────────┼───────┼────────────┤",
    }

    for i, f in ipairs(funcs) do
      local display_name = f.name:sub(1, 17) .. (f.name:len() > 17 and "…" or "")
      local loc_str = string.format("%s:%d", current_filename, f.line)
      local display_loc = loc_str:sub(1, 10) .. (loc_str:len() > 10 and "…" or "")

      local cyc_display = f.cyc and string.format("%3d", f.cyc) or "    -"
      local big_o_display = string.format("%-5s", f.big_o)
      local res_display = string.format("%-10s", f.resources)

      table.insert(
        table_lines,
        string.format(
          "│%3d│ %-17s │ %-10s │ %7s   │ %-5s │ %-10s │",
          i,
          display_name,
          display_loc,
          cyc_display,
          big_o_display,
          res_display
        )
      )
    end

    table.insert(
      table_lines,
      "└─┴─────────────────┴────────────┴───────────┴───────┴────────────┘"
    )
    return table.concat(table_lines, "\n")
  end
end

return M
