local utils = require("appsec.utils")

local M = {}

--- Список функцій з метриками для Go
---@return fun(): string
function M.list_functions_step()
  return function()
    local current_filepath = vim.fn.expand("%:p")
    if current_filepath == "" or current_filepath:match("^%[") then
      current_filepath = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
    end

    local current_filename = vim.fn.fnamemodify(current_filepath, ":t")
    if current_filename == "" or not current_filename:match("%.go$") then
      return string.format("ℹ️ Not a Go file: %s", current_filename)
    end
    if vim.fn.filereadable(current_filepath) ~= 1 then
      return string.format("ℹ️ File not readable: %s", current_filename)
    end

    local file_lines = vim.fn.readfile(current_filepath)
    if not file_lines or #file_lines == 0 then
      return "ℹ️ Empty file"
    end

    local funcs = {}
    local name_pat = "[%a_][%w_]*"

    for i, line in ipairs(file_lines) do
      line = line:gsub("\r", "")
      local fname = line:match("^%s*func%s+(" .. name_pat .. ")%s*%(")
      if fname then
        table.insert(funcs, { name = fname, line = i })
      end
    end

    if #funcs == 0 then
      return string.format("ℹ️ No functions found in %s", current_filename)
    end

    -- Збір метрик (gocyclo)
    local complexity_data = {}
    if vim.fn.executable("gocyclo") == 1 then
      local cyc_output = vim.fn.system(string.format("gocyclo -over 0 '%s' 2>/dev/null", current_filepath))
      for cyc, lnum, fname in cyc_output:gmatch("(%d+)%s+[^:]+:(%d+):%d+:%s*([%w_]+)") do
        complexity_data[fname] = tonumber(cyc)
      end
    end

    -- Аналіз кожної функції
    for _, f in ipairs(funcs) do
      local start_line = f.line
      local end_line = #file_lines

      for i = start_line + 1, #file_lines do
        if file_lines[i]:match("^%s*func%s+") then
          end_line = i - 1
          break
        end
      end

      local loc = end_line - start_line + 1
      local body = table.concat(utils.slice(file_lines, start_line, end_line), "\n")

      local big_o = "O(1)"
      if body:match("for%s+.*range") or body:match("for%s+%w+%s*:=") then
        big_o = body:match("for%s+.*for%s+") and "O(n²)" or "O(n)"
      elseif body:match(f.name .. "%s*%(") then
        big_o = "O(log n)"
      end

      local resources = "🟢 Low"
      if body:match("make%(") then
        resources = "🟡 Med"
      end
      if body:match("append%s*%(") or body:match("go%s+%w+%s*%(") or body:match("make%s*%(%s*chan") then
        resources = "🔴 High"
      end
      local cyc = complexity_data[f.name]
      if cyc and cyc >= 20 then
        resources = "🔴 High"
      elseif cyc and cyc >= 10 then
        resources = resources == "🟢 Low" and "🟡 Med" or resources
      end

      f.loc, f.cyc, f.big_o, f.resources = loc, cyc, big_o, resources
    end

    -- Форматування таблиці
    local lines = {
      string.format("📋 Functions in %s (%d total):", current_filename, #funcs),
      "┌─┬─────────────────┬────────────┬───────┬───────────┬───────┬────────────┐",
      "│#│ Function        │ Location   │  LOC   │ Complexity│ Big O │ Resources  │",
      "├─┼─────────────────┼────────────┼───────┼───────────┼───────┼────────────┤",
    }

    for i, f in ipairs(funcs) do
      local dn = f.name:sub(1, 17) .. (f.name:len() > 17 and "…" or "")
      local dl = string.format("%s:%d", current_filename, f.line):sub(1, 10)
      local cyc_str = f.cyc and string.format("%3d", f.cyc) or "    -"

      table.insert(
        lines,
        string.format(
          "│%3d│ %-17s │ %-10s │ %4d  │ %7s   │ %-5s │ %-10s │",
          i,
          dn,
          dl,
          f.loc,
          cyc_str,
          f.big_o,
          f.resources
        )
      )
    end
    table.insert(
      lines,
      "└─┴─────────────────┴────────────┴───────┴───────────┴───────┴────────────┘"
    )
    table.insert(lines, "• LOC: Lines of Code | 🟢 Low: <20 | 🟡 Med: 20-50 | 🔴 High: >50")

    return table.concat(lines, "\n")
  end
end

return M
