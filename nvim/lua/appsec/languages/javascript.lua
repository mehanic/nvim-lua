local utils = require("appsec.utils")

local M = {}

--- Список функцій/класів з метриками для JS/TS
---@return fun(): string
function M.list_functions_step()
  return function()
    -- 1. Пробуємо отримати поточний файл
    local current_filepath = vim.fn.expand("%:p")
    local current_filename = vim.fn.fnamemodify(current_filepath, ":t")

    -- 2. Якщо це не JS/TS або файл не читається, шукаємо серед відкритих буферів
    local is_js_ts = current_filename:match("%.js[x]?$") or current_filename:match("%.ts[x]?$")
    if not is_js_ts or vim.fn.filereadable(current_filepath) ~= 1 then
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          if bufname:match("%.js[x]?$") or bufname:match("%.ts[x]?$") then
            if vim.fn.filereadable(bufname) == 1 then
              current_filepath = bufname
              current_filename = vim.fn.fnamemodify(current_filepath, ":t")
              break
            end
          end
        end
      end
    end

    -- 3. Фінальна перевірка
    local is_js_ts_final = current_filename:match("%.js[x]?$") or current_filename:match("%.ts[x]?$")
    if not is_js_ts_final then
      return "ℹ️ No JS/TS file detected. Open a .js/.jsx/.ts/.tsx file first."
    end
    if vim.fn.filereadable(current_filepath) ~= 1 then
      return string.format("ℹ️ Cannot read: %s", current_filename)
    end

    -- Крок 1: Надійний Lua-парсер для JS/TS
    local file_lines = vim.fn.readfile(current_filepath)
    if not file_lines or #file_lines == 0 then
      return string.format("ℹ️ Empty or unreadable: %s", current_filename)
    end

    local funcs = {}
    local name_pat = "[%a_$][%w_$]*" -- JS імена можуть містити $ та _

    for i, line in ipairs(file_lines) do
      line = line:gsub("\r", "")
      local kind, n

      -- 📦 Класи: class Name, export class Name, abstract class Name
      n = line:match("^%s*(export%s+)?(abstract%s+)?class%s+(" .. name_pat .. ")")
      if n then
        kind = "class"
      else
        -- 🔹 Async функції: async function name
        n = line:match("^%s*async%s+function%s+(" .. name_pat .. ")%s*%(")
        if n then
          kind = "async function"
        else
          -- 🔹 Звичайні функції: function name
          n = line:match("^%s*function%s+(" .. name_pat .. ")%s*%(")
          if n then
            kind = "function"
          else
            -- 🔹 Стрілочні/змінні: const/let/var name = (async)? (...) =>
            local is_async, arrow_name = line:match("^%s*(const|let|var)%s+(" .. name_pat .. ")%s*=%s*(async%s+)?%(")
            if arrow_name then
              n = arrow_name
              kind = is_async and "async arrow" or "arrow"
            else
              -- 🔹 Методи в класах: name(...) { або async name(...) {
              n = line:match("^%s*(async%s+)?(" .. name_pat .. ")%s*%([^)]*%)[^{]*{")
              if n and n ~= "function" and n ~= "async" then
                kind = n:match("async") and "async method" or "method"
                n = line:match("^%s*async%s+(" .. name_pat .. ")%s*%(") or n
              end
            end
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

    -- Крок 2: Складність (опціонально: eslint complexity)
    local complexity_data = {}
    if vim.fn.executable("eslint") == 1 then
      local eslint_out = vim.fn.system(
        string.format(
          "eslint --rule 'complexity: error' --no-eslintrc --no-ignore --format json '%s' 2>/dev/null",
          current_filepath
        )
      )
      local ok, data = pcall(vim.fn.json_decode, eslint_out)
      if ok and data and data[1] and data[1].messages then
        for _, msg in ipairs(data[1].messages) do
          if msg.ruleId == "complexity" and msg.message:match("maximum of") then
            local cyc = msg.message:match("maximum of (%d+)")
            if cyc then
              complexity_data[msg.line] = tonumber(cyc)
            end
          end
        end
      end
    end

    for _, f in ipairs(funcs) do
      local start_line = f.line
      local end_line = #file_lines

      -- 🔍 Знаходимо кінець функції/класу
      -- Для JS/TS шукаємо наступне визначення на тому ж або вищому рівні відступу
      local start_indent = file_lines[start_line]:match("^(%s*)")
      for i = start_line + 1, #file_lines do
        local next_line = file_lines[i]
        local next_indent = next_line:match("^(%s*)") or ""
        -- Якщо наступний рядок не порожній і має <= відступ + є визначенням
        if
          #next_indent <= #start_indent
          and (
            next_line:match("^%s*function%s+")
            or next_line:match("^%s*async%s+function%s+")
            or next_line:match("^%s*class%s+")
            or next_line:match("^%s*(const|let|var)%s+%a[%w_$]*%s*=%s*(async%s+)?%(")
            or next_line:match("^%s*(export%s+)?class%s+")
          )
        then
          end_line = i - 1
          break
        end
      end

      local loc = end_line - start_line + 1
      local cyc = complexity_data[start_line]
      local body = table.concat(utils.slice(file_lines, start_line, end_line), "\n")

      -- 🔹 Big O естимація (JS/TS специфіка)
      local big_o = "O(1)"
      local has_loop = body:match("for%s+%(")
        or body:match("while%s+%(")
        or body:match("%.forEach%s*%(")
        or body:match("%.map%s*%(")
        or body:match("%.filter%s*%(")
        or body:match("%.reduce%s*%(")

      if has_loop then
        local nested = body:match("for%s+%(.+for%s+%(")
          or body:match("while%s+%(.+while%s+%(")
          or body:match("%.forEach%s*%(%.+%.forEach%s*%(")
          or body:match("%.map%s*%(%.+%.map%s*%(")
          or (body:match("for%s+%(") and body:match("%.forEach%s*%("))
        big_o = nested and "O(n²)" or "O(n)"
      elseif body:match(f.name .. "%s*%(") then
        big_o = "O(log n)" -- рекурсія
      end

      -- 🔹 Resource hints (JS/TS)
      local resources = "🟢 Low"
      if
        body:match("new%s+Array%(")
        or body:match("new%s+Map%(")
        or body:match("new%s+Set%(")
        or body:match("new%s+Object%(")
        or body:match("JSON%.parse%(")
      then
        resources = "🟡 Med"
      end
      if
        body:match("Promise%.all%(")
        or body:match("Promise%.race%(")
        or body:match("async%s+function")
        or body:match("await%s+")
      then
        resources = resources == "🟢 Low" and "🟡 Med" or " High"
      end
      if
        body:match("fetch%(")
        or body:match("axios%.")
        or body:match("import%(")
        or body:match("setTimeout%(")
        or body:match("setInterval%(")
        or body:match("requestAnimationFrame%(")
      then
        resources = " High"
      end
      if cyc and cyc >= 20 then
        resources = " High"
      elseif cyc and cyc >= 10 then
        resources = resources == " Low" and "🟡 Med" or resources
      end

      f.loc = loc
      f.cyc = cyc
      f.big_o = big_o
      f.resources = resources
    end

    -- Крок 4: Форматуємо таблицю
    local table_lines = {
      string.format(" JS/TS Functions in %s (%d total):", current_filename, #funcs),
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
