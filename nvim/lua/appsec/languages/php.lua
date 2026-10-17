local utils = require("appsec.utils")

local M = {}

--- Список функцій/типів з метриками для PHP
---@return fun(): string
function M.list_functions_step()
  -- 🔹 КЛЮЧОВЕ: захоплюємо шлях ЗАРАЗ, при конфігурації пайплайну
  local captured_filepath = vim.fn.expand("%:p")
  if captured_filepath == "" or captured_filepath:match("^%[") then
    captured_filepath = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  end

  -- 🔹 Повертаємо функцію, яка використовує ЗАХОПЛЕНИЙ шлях
  return function()
    local current_filepath = captured_filepath
    local current_filename = vim.fn.fnamemodify(current_filepath, ":t")

    -- 🔹 Перевірки
    if current_filename == "" or not current_filename:match("%.php$") then
      return string.format("ℹ️ Not a PHP file. Got: '%s'", current_filename ~= "" and current_filename or "(empty)")
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
      local clean = line:gsub("//.*$", ""):gsub("/%*.-%*/", ""):gsub("#.*$", "")
      local n, kind

      -- 🔹 Функції: function name(
      n = clean:match("^%s*function%s+(" .. name_pat .. ")%s*%(")
      if n then
        kind = "function"
      end

      -- 🔹 Методи з модифікаторами (Lua не підтримує (?:...))
      if not n then
        n = clean:match("^%s*public%s+function%s+(" .. name_pat .. ")%s*%(")
        if n then
          kind = "public function"
        end
      end
      if not n then
        n = clean:match("^%s*protected%s+function%s+(" .. name_pat .. ")%s*%(")
        if n then
          kind = "protected function"
        end
      end
      if not n then
        n = clean:match("^%s*private%s+function%s+(" .. name_pat .. ")%s*%(")
        if n then
          kind = "private function"
        end
      end

      -- 🔹 Класи / Інтерфейси / Трейти / Enum
      if not n then
        n = clean:match("^%s*class%s+(" .. name_pat .. ")")
        if n then
          kind = "class"
        end
      end
      if not n then
        n = clean:match("^%s*interface%s+(" .. name_pat .. ")")
        if n then
          kind = "interface"
        end
      end
      if not n then
        n = clean:match("^%s*trait%s+(" .. name_pat .. ")")
        if n then
          kind = "trait"
        end
      end
      if not n then
        n = clean:match("^%s*enum%s+(" .. name_pat .. ")")
        if n then
          kind = "enum"
        end
      end

      if n then
        table.insert(funcs, { name = n, line = i, kind = kind })
      end
    end

    if #funcs == 0 then
      return string.format("ℹ️ No functions/types found in %s", current_filename)
    end

    for _, f in ipairs(funcs) do
      local start_line = f.line
      local end_line = #file_lines

      -- Знаходимо кінець блоку
      for i = start_line + 1, #file_lines do
        local next = file_lines[i]:gsub("//.*$", ""):gsub("/%*.-%*/", "")
        if
          next:match("^%s*function%s+" .. name_pat)
          or next:match("^%s*public%s+function%s+" .. name_pat)
          or next:match("^%s*protected%s+function%s+" .. name_pat)
          or next:match("^%s*private%s+function%s+" .. name_pat)
          or next:match("^%s*class%s+" .. name_pat)
          or next:match("^%s*interface%s+" .. name_pat)
          or next:match("^%s*trait%s+" .. name_pat)
          or next:match("^%s*enum%s+" .. name_pat)
        then
          end_line = i - 1
          break
        end
      end

      f.loc = end_line - start_line + 1
      local body = table.concat(utils.slice(file_lines, start_line, end_line), "\n")

      -- 🔹 Big O
      f.big_o = "O(1)"
      local has_loop = body:match("for%s+%(") or body:match("while%s+%(") or body:match("foreach%s+%(")
      if has_loop then
        f.big_o = (body:match("foreach%s+%(.+foreach%s+%(") or body:match("for%s+%(.+for%s+%(")) and "O(n²)" or "O(n)"
      end

      -- 🔹 Resources / Security
      f.resources = "🟢 Low"
      if body:match("new%s+PDO%(") or body:match("json_decode%(") then
        f.resources = "🟡 Med"
      end
      if body:match("exec%(") or body:match("eval%(") or body:match("unserialize%(") then
        f.resources = "🔴 High"
      end
      if body:match("query%(['\"].-SELECT.-%.%)") then
        f.resources = "🔴 High"
      end -- SQL injection
    end

    -- 🔹 Форматування таблиці
    local table_lines = {
      string.format("🐘 PHP Functions/Types in %s (%d total):", current_filename, #funcs),
      "┌──────────────────┬────────────┬───────────┬───────┬────────────┐",
      "│#│ Item/Function   │ Location   │ LOC       │ Big O │ Resources  │",
      "├─┼─────────────────┼────────────┼───────────┼───────┼────────────┤",
    }
    for i, f in ipairs(funcs) do
      local dn = f.name:sub(1, 17) .. (f.name:len() > 17 and "…" or "")
      local dl = string.format("%s:%d", current_filename, f.line):sub(1, 10)
      table.insert(
        table_lines,
        string.format(
          "│%3d│ %-17s │ %-10s │ %3d   │ %-5s │ %-10s │",
          i,
          dn,
          dl,
          f.loc,
          f.big_o,
          f.resources
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
      "📊 LOC: рядки | 🟢<20 🟡20-50 🔴>50 | Big O: складність | Resources: 🟢Low Med 🔴High"
    )

    return table.concat(table_lines, "\n")
  end
end

return M
