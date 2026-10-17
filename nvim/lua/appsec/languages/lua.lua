local utils = require("appsec.utils")

local M = {}

--- Список функцій/типів з метриками для Lua
---@return fun(): string
function M.list_functions_step()
  return function()
    -- 🔹 Захоплюємо шлях
    local captured_filepath = vim.fn.expand("%:p")
    if captured_filepath == "" or captured_filepath:match("^%[") then
      captured_filepath = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
    end

    local current_filepath = captured_filepath
    local current_filename = vim.fn.fnamemodify(current_filepath, ":t")

    -- 🔹 Перевірки
    if current_filename == "" or not current_filename:match("%.lua$") then
      return string.format("ℹ️ Not a Lua file. Got: '%s'", current_filename ~= "" and current_filename or "(empty)")
    end
    if vim.fn.filereadable(current_filepath) ~= 1 then
      return string.format("ℹ️ Cannot read: %s", current_filename)
    end

    local file_lines = vim.fn.readfile(current_filepath)
    if not file_lines or #file_lines == 0 then
      return string.format("ℹ️ Empty or unreadable: %s", current_filename)
    end

    local funcs = {}
    local name_pat = "[%a_][%w_]*"

    for i, line in ipairs(file_lines) do
      line = line:gsub("\r", "")
      -- Видаляємо коментарі
      local clean = line:gsub("%-%-.*$", ""):gsub("%-%-%[%[.-%]%]", "")

      local n, kind

      -- 1. local function name(
      n = clean:match("^%s*local%s+function%s+(" .. name_pat .. ")%s*%(")
      if n then
        kind = "local function"
      end

      -- 2. function name( (глобальна)
      if not n then
        n = clean:match("^%s*function%s+(" .. name_pat .. ")%s*%(")
        if n then
          kind = "function"
        end
      end

      -- 3. function Class:method(
      if not n then
        n = clean:match("^%s*function%s+(" .. name_pat .. "):(" .. name_pat .. ")%s*%(")
        if n then
          local class_name = clean:match("^%s*function%s+(" .. name_pat .. ")")
          local method_name = clean:match("^%s*function%s+" .. name_pat .. ":(" .. name_pat .. ")")
          n = class_name .. ":" .. method_name
          kind = "method (:)"
        end
      end

      -- 4. function Class.method(
      if not n then
        n = clean:match("^%s*function%s+(" .. name_pat .. "%." .. name_pat .. ")%s*%(")
        if n then
          kind = "method (.)"
        end
      end

      -- 5. local name = function(
      if not n then
        n = clean:match("^%s*local%s+(" .. name_pat .. ")%s*=%s*function%s*%(")
        if n then
          kind = "local = function"
        end
      end

      -- 6. name = function(
      if not n then
        n = clean:match("^%s*(" .. name_pat .. ")%s*=%s*function%s*%(")
        if n then
          kind = "= function"
        end
      end

      if n then
        table.insert(funcs, { name = n, line = i, kind = kind })
      end
    end

    if #funcs == 0 then
      return string.format("ℹ️ No functions found in %s", current_filename)
    end

    for _, f in ipairs(funcs) do
      local start_line = f.line
      local end_line = #file_lines

      -- Знаходимо кінець функції
      for i = start_line + 1, #file_lines do
        local next = file_lines[i]:gsub("%-%-.*$", ""):gsub("%-%-%[%[.-%]%]", "")
        if
          next:match("^%s*local%s+function%s+" .. name_pat)
          or next:match("^%s*function%s+" .. name_pat .. "%s*%(")
          or next:match("^%s*function%s+" .. name_pat .. "[:%.]" .. name_pat)
          or next:match("^%s*local%s+" .. name_pat .. "%s*=%s*function")
          or next:match("^%s*" .. name_pat .. "%s*=%s*function")
        then
          end_line = i - 1
          break
        end
      end

      f.loc = end_line - start_line + 1
      local body = table.concat(utils.slice(file_lines, start_line, end_line), "\n")

      -- 🔹 Big O (Lua ідіоми)
      f.big_o = "O(1)"
      local has_loop = body:match("for%s+")
        or body:match("while%s+")
        or body:match("repeat%s+")
        or body:match("ipairs%s*%(")
        or body:match("pairs%s*%(")
        or body:match("%.next%s*%(")
      if has_loop then
        local nested = body:match("for%s+.*for%s+")
          or body:match("while%s+.*while%s+")
          or body:match("ipairs%s*%(.+ipairs%s*%(")
        f.big_o = nested and "O(n²)" or "O(n)"
      elseif body:match(f.name .. "%s*%(") then
        f.big_o = "O(log n)"
      end

      -- 🔹 Resources / Security hints
      f.resources = "🟢 Low"
      if
        body:match("require%s*%(")
        or body:match("io%.open%s*%(")
        or body:match("io%.popen%s*%(")
        or body:match("table%.insert%s*%(")
        or body:match("table%.remove%s*%(")
        or body:match("table%.concat%s*%(")
      then
        f.resources = "🟡 Med"
      end
      if
        body:match("os%.execute%s*%(")
        or body:match("os%.spawn%s*%(")
        or body:match("load%s*%(")
        or body:match("loadstring%s*%(")
        or body:match("debug%.setmetatable%s*%(")
        or body:match("coroutine%.create%s*%(")
        or body:match("getfenv%s*%(")
        or body:match("setfenv%s*%(")
      then
        f.resources = "🔴 High"
      end
    end

    -- 🔹 Форматування таблиці
    local table_lines = {
      string.format("🌙 Lua Functions in %s (%d total):", current_filename, #funcs),
      "┌─┬─────────────────┬────────────┬───────────┬───────┬────────────┐",
      "│#│ Function        │ Location   │ LOC       │ Big O │ Resources  │",
      "├─┼─────────────────┼────────────┼───────────┼───────┼────────────┤",
    }
    for i, f in ipairs(funcs) do
      local dn = f.name:sub(1, 17) .. (f.name:len() > 17 and "…" or "")
      local dl = string.format("%s:%d", current_filename, f.line):sub(1, 10)
      local loc_display = string.format("%3d", f.loc)
      local big_o_display = string.format("%-5s", f.big_o)
      local res_display = string.format("%-10s", f.resources)

      table.insert(
        table_lines,
        string.format(
          "│%3d│ %-17s │ %-10s │ %7s   │ %-5s │ %-10s │",
          i,
          dn,
          dl,
          loc_display,
          big_o_display,
          res_display
        )
      )
    end
    table.insert(
      table_lines,
      "└─┴─────────────────┴────────────┴───────────┴───────┴────────────┘"
    )
    table.insert(table_lines, "")
    table.insert(
      table_lines,
      "📊 LOC: рядки | 🟢<20 🟡20-50 🔴>50 | Big O: складність | Resources: 🟢Low 🟡Med 🔴High"
    )

    return table.concat(table_lines, "\n")
  end
end

return M
