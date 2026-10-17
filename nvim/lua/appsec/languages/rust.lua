local utils = require("appsec.utils")

local M = {}

--- Список функцій/типів з метриками для Rust
---@return fun(): string
function M.list_functions_step()
  return function()
    local current_filepath = vim.fn.expand("%:p")
    if current_filepath == "" or current_filepath:match("^%[") then
      current_filepath = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
    end
    if current_filepath == "" or not vim.fn.filereadable(current_filepath) then
      local rs_files = vim.fn.glob(vim.fn.getcwd() .. "/*.rs", false, true)
      if #rs_files > 0 then
        current_filepath = rs_files[1]
      end
    end

    local current_filename = vim.fn.fnamemodify(current_filepath, ":t")
    if current_filename == "" or not current_filename:match("%.rs$") then
      return "ℹ️ No Rust file detected. Open a .rs file first."
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
      local kind, n

      -- fn / async fn / pub fn
      n = line:match("^%s*fn%s+(" .. name_pat .. ")%s*[%(%<]")
      if n then
        kind = "fn"
      else
        n = line:match("^%s*async%s+fn%s+(" .. name_pat .. ")%s*[%(%<]")
        if n then
          kind = "async fn"
        else
          n = line:match("^%s*pub%s+fn%s+(" .. name_pat .. ")%s*[%(%<]")
          if n then
            kind = "pub fn"
          else
            n = line:match("^%s*pub%s+async%s+fn%s+(" .. name_pat .. ")%s*[%(%<]")
            if n then
              kind = "pub async fn"
            end
          end
        end
      end

      -- struct / pub struct
      if not n then
        n = line:match("^%s*struct%s+(" .. name_pat .. ")")
        if n then
          kind = "struct"
        else
          n = line:match("^%s*pub%s+struct%s+(" .. name_pat .. ")")
          if n then
            kind = "pub struct"
          end
        end
      end

      -- enum / pub enum
      if not n then
        n = line:match("^%s*enum%s+(" .. name_pat .. ")")
        if n then
          kind = "enum"
        else
          n = line:match("^%s*pub%s+enum%s+(" .. name_pat .. ")")
          if n then
            kind = "pub enum"
          end
        end
      end

      -- trait / pub trait
      if not n then
        n = line:match("^%s*trait%s+(" .. name_pat .. ")")
        if n then
          kind = "trait"
        else
          n = line:match("^%s*pub%s+trait%s+(" .. name_pat .. ")")
          if n then
            kind = "pub trait"
          end
        end
      end

      -- mod / pub mod
      if not n then
        n = line:match("^%s*mod%s+(" .. name_pat .. ")")
        if n then
          kind = "mod"
        else
          n = line:match("^%s*pub%s+mod%s+(" .. name_pat .. ")")
          if n then
            kind = "pub mod"
          end
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
        local next = file_lines[i]
        if
          next:match("^%s*fn%s+" .. name_pat)
          or next:match("^%s*async%s+fn%s+" .. name_pat)
          or next:match("^%s*pub%s+fn%s+" .. name_pat)
          or next:match("^%s*struct%s+" .. name_pat)
          or next:match("^%s*enum%s+" .. name_pat)
          or next:match("^%s*trait%s+" .. name_pat)
          or next:match("^%s*mod%s+" .. name_pat)
        then
          end_line = i - 1
          break
        end
      end

      f.loc = end_line - start_line + 1
      local body = table.concat(utils.slice(file_lines, start_line, end_line), "\n")

      -- 🔹 Big O (Rust ідіоми)
      f.big_o = "O(1)"
      local has_loop = body:match("for%s+.*in%s+")
        or body:match("while%s+")
        or body:match("%.iter%(")
        or body:match("%.map%(")
        or body:match("%.filter%(")
        or body:match("%.fold%(")
      if has_loop then
        local nested = body:match("for%s+.*for%s+")
          or body:match("while%s+.*while%s+")
          or body:match("%.iter%(%..*%.map%(")
          or body:match("%.chain%(")
        f.big_o = nested and "O(n²)" or "O(n)"
      elseif body:match(f.name .. "%s*%(") then
        f.big_o = "O(log n)"
      end

      -- 🔹 Resource hints (Rust специфіка)
      f.resources = "🟢 Low"
      if
        body:match("Vec::new%(")
        or body:match("Vec::with_capacity%(")
        or body:match("String::from%(")
        or body:match("Box::new%(")
      then
        f.resources = "🟡 Med"
      end
      if
        body:match("Arc<")
        or body:match("Rc<")
        or body:match("Mutex<")
        or body:match("channel%(")
        or body:match("tokio::spawn")
        or body:match("async%s+")
      then
        f.resources = f.resources == "🟢 Low" and "🟡 Med" or "🔴 High"
      end
      if body:match("unsafe%s+") or body:match("%.unwrap%(%s*%)") then
        f.resources = "🔴 High"
      end
    end

    -- 🔹 Форматування таблиці
    local table_lines = {
      string.format("🦀 Rust Functions/Types in %s (%d total):", current_filename, #funcs),
      "┌─┬─────────────────┬────────────┬───────────┬───────┬────────────┐",
      "│#│ Item/Function   │ Location   │ LOC       │ Big O │ Resources  │",
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
    table.insert(table_lines, "• Big O: O(1)=конст, O(n)=лінійна, O(n²)=квадратична")
    table.insert(table_lines, "LOC: Lines of Code | 🟢 Low: <20 LOC | 🟡 Med: 20-50 LOC | 🔴 High: >50 LOC")
    return table.concat(table_lines, "\n")
  end
end

return M
