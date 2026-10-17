local utils = require("appsec.utils")

local M = {}

--- Список функцій з метриками для Bash/Shell
---@return fun(): string
function M.list_functions_step()
  return function()
    local captured_filepath = vim.fn.expand("%:p")
    if captured_filepath == "" or captured_filepath:match("^%[") then
      captured_filepath = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
    end
    if captured_filepath == "" or not vim.fn.filereadable(captured_filepath) then
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          local fname = vim.fn.fnamemodify(bufname, ":t")
          if
            fname:match("%.sh$")
            or fname:match("%.bash$")
            or fname:match("%.zsh$")
            or fname:match("%.ksh$")
            or fname:match("%.fish$")
            or vim.api.nvim_buf_get_option(bufnr, "filetype"):match("^sh$")
            or vim.api.nvim_buf_get_option(bufnr, "filetype"):match("^bash$")
          then
            if vim.fn.filereadable(bufname) == 1 then
              captured_filepath = bufname
              break
            end
          end
        end
      end
    end
    if captured_filepath == "" or not vim.fn.filereadable(captured_filepath) then
      local sh_files = vim.fn.glob(vim.fn.getcwd() .. "/*.{sh,bash,zsh,ksh}", false, true)
      if #sh_files > 0 then
        captured_filepath = sh_files[1]
      end
    end

    local current_filename = vim.fn.fnamemodify(captured_filepath, ":t")
    local is_shell = current_filename:match("%.sh$")
      or current_filename:match("%.bash$")
      or current_filename:match("%.zsh$")
      or current_filename:match("%.ksh$")
      or vim.bo.filetype:match("^sh$")
      or vim.bo.filetype:match("^bash$")

    if not is_shell then
      return string.format("ℹ️ Not a Shell script. Open .sh/.bash/.zsh file (got: %s)", current_filename)
    end
    if vim.fn.filereadable(captured_filepath) ~= 1 then
      return string.format("ℹ️ Cannot read: %s", current_filename)
    end

    local file_lines = vim.fn.readfile(captured_filepath)
    if not file_lines or #file_lines == 0 then
      return "ℹ️ Empty file"
    end

    local funcs = {}
    local name_pat = "[%a_][%w_]*"
    for i, line in ipairs(file_lines) do
      line = line:gsub("\r", "")
      local n
      n = line:match("^%s*function%s+(" .. name_pat .. ")%s*%(")
      if not n then
        n = line:match("^%s*(" .. name_pat .. ")%s*%(%s*%)")
      end
      if not n then
        n = line:match("^%s*(" .. name_pat .. ")%s*%(%s*%)%s*{")
      end
      if n then
        table.insert(funcs, { name = n, line = i })
      end
    end

    if #funcs == 0 then
      return string.format("ℹ️ No functions found in %s", current_filename)
    end

    -- 🔹 Хелпер для розрахунку складності (евристика)
    local function calc_complexity(text)
      local c = 1
      local patterns = { "if%s+", "elif%s+", "for%s+", "while%s+", "until%s+", "case%s+", "&&", "||" }
      local clean = text:gsub("#.-\n", "\n"):gsub('%b""', ""):gsub("%b''", "")
      for _, pat in ipairs(patterns) do
        for _ in clean:gmatch(pat) do
          c = c + 1
        end
      end
      return c
    end

    for _, f in ipairs(funcs) do
      local start_line = f.line
      local end_line = #file_lines
      for i = start_line + 1, #file_lines do
        local next = file_lines[i]
        if
          next:match("^%s*function%s+" .. name_pat)
          or next:match("^%s*" .. name_pat .. "%s*%(%s*%)")
          or next:match("^%s*" .. name_pat .. "%s*%(%s*%)%s*{")
        then
          end_line = i - 1
          break
        end
      end

      f.loc = end_line - start_line + 1
      local body = table.concat(utils.slice(file_lines, start_line, end_line), "\n")

      -- 1. Complexity
      f.complexity = calc_complexity(body)

      -- 2. Big O
      f.big_o = "O(1)"
      local has_for = body:match("for%s+") ~= nil
      local has_while = body:match("while%s+") ~= nil
      if has_for or has_while then
        if body:match("for%s+.*for%s+") or body:match("while%s+.*while%s+") or (has_for and has_while) then
          f.big_o = "O(n²)"
        else
          f.big_o = "O(n)"
        end
      end

      -- 3. Resources & Security
      f.resources = "🟢 Low"
      if body:match("curl%s+") or body:match("wget%s+") or body:match("ssh%s+") or body:match("scp%s+") then
        f.resources = "🟡 Med"
      end
      if
        body:match("eval%s+")
        or body:match("`[^`]+`")
        or body:match("%$%b()")
        or body:match("exec%s+")
        or body:match("set%s+-x")
      then
        f.resources = "🔴 High"
      end

      -- Вплив складності на ресурси
      if f.complexity >= 20 then
        f.resources = "🔴 High"
      elseif f.complexity >= 10 then
        f.resources = f.resources == "🟢 Low" and "🟡 Med" or f.resources
      end
    end

    -- 🔹 Форматування таблиці
    local table_lines = {
      string.format("🐚 Shell Functions in %s (%d total):", current_filename, #funcs),
      "┌─┬─────────────────┬────────────┬───────┬───────────┬───────┬────────────┐",
      "│#│ Function        │ Location   │ LOC   │ Complexity│ Big O │ Resources  │",
      "├─┼─────────────────┼────────────┼───────┼───────────┼───────┼────────────┤",
    }
    for i, f in ipairs(funcs) do
      local dn = f.name:sub(1, 17) .. (f.name:len() > 17 and "…" or "")
      local dl = string.format("%s:%d", current_filename, f.line):sub(1, 10)
      local loc_display = string.format("%4d", f.loc)
      local comp_display = string.format("%7d", f.complexity)
      local big_o_display = string.format("%-5s", f.big_o)
      local res_display = string.format("%-10s", f.resources)

      table.insert(
        table_lines,
        string.format(
          "│%3d│ %-17s │ %-10s │ %4s │ %7s   │ %-5s │ %-10s │",
          i,
          dn,
          dl,
          loc_display,
          comp_display,
          big_o_display,
          res_display
        )
      )
    end
    table.insert(
      table_lines,
      "└─┴─────────────────┴────────────┴──────┴───────────┴───────┴────────────┘"
    )
    table.insert(table_lines, "")
    table.insert(table_lines, "• Big O: O(1)=конст, O(n)=лінійна, O(n²)=квадратична")
    table.insert(table_lines, "• LOC: Lines of Code | 🟢 Low: <20 LOC | 🟡 Med: 20-50 LOC | 🔴 High: >50 LOC")

    return table.concat(table_lines, "\n")
  end
end

return M
