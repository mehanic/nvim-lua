local utils = require("appsec.utils")

local M = {}

-- ============================================================================
-- 🔹 1. ГЛОБАЛЬНА КОНФІГУРАЦІЯ
-- ============================================================================
M.config = {
  timeout = "5m",
  tests = false,
  languages = {
    go = {
      tool = "golangci-lint",
      enabled = true,
      args = function(cwd)
        return string.format(
          "golangci-lint run --timeout=%s --tests=%s --disable-all "
            .. "--enable=gocyclo,gocognit,funlen,cyclop,ineffassign,unparam,prealloc,copyloopvar,gosec,errcheck,staticcheck "
            .. "--out-format=json --exclude-use-default=false --max-issues-per-linter=0 "
            .. "--gocyclo.min-complexity=15 --gocognit.min-complexity=20 --funlen.lines=100 --funlen.statements=50 "
            .. "--prealloc.simple --prealloc.range-loops --gosec.excludes=G104,G307 "
            .. "./... 2>&1 || echo '{}'",
          M.config.timeout,
          tostring(M.config.tests)
        )
      end,
    },
    python = {
      tool = "ruff",
      enabled = true,
      args = function(cwd)
        return string.format(
          "ruff check --select=C901,PLR0911,PLR0912,PLR0915,S,F,W,E,PLC0414,PLR1702,SIM101 "
            .. "--line-length=120 --output-format=json --respect-gitignore %s 2>&1 || echo '{}'",
          vim.fn.shellescape(cwd)
        )
      end,
    },
    -- ⚠️ ТУТ МОЖНА ДОДАТИ rust, php, javascript за аналогією
  },
}

-- ============================================================================
-- 🔹 2. ОСНОВНИЙ АНАЛІЗ (analyze_sync)
-- ============================================================================
function M.analyze_sync(ft, cwd)
  local lang_cfg = M.config.languages[ft]
  if not lang_cfg or not lang_cfg.enabled then
    return string.format("ℹ️ Статичний аналіз не підтримується для %s", ft), 0
  end

  local tool = lang_cfg.tool
  if vim.fn.executable(tool) ~= 1 then
    return string.format("⚠️ %s not found. Install: %s", tool, utils.get_install_hint(tool)), 127
  end

  local cmd = lang_cfg.args and lang_cfg.args(cwd) or string.format("%s run . 2>&1 || echo '{}'", tool)
  local output = vim.fn.system(string.format("cd '%s' && %s", cwd, cmd))
  local code = vim.v.shell_error

  if code == 0 or output:match("^{}$") or output:match("OK$") then
    return string.format("✅ %s: No critical issues", tool), 0
  end

  local ok, data = pcall(vim.fn.json_decode, output)
  if ok and data then
    local count = 0
    if data.Issues then
      count = #data.Issues
    elseif data.violations then
      count = #data.violations
    elseif data.results then
      count = #data.results
    end

    if count == 0 then
      return string.format("✅ %s: OK", tool), 0
    end
    return string.format("⚠️ %s: %d issue(s) found", tool, count), 1
  end

  return string.format("⚠️ %s: %s", tool, output:sub(1, 150):gsub("%s+$", "")), code
end

-- ============================================================================
-- 🔹 3. LAZY LOADING ДЛЯ СПИСКІВ ФУНКЦІЙ
-- ============================================================================
-- Ці функції завантажують модуль мови ТІЛЬКИ коли він потрібен!

local function get_lang_module(ft)
  local map = {
    go = "go",
    python = "python",
    rust = "rust",
    php = "php",
    lua = "lua",
    javascript = "javascript",
    typescript = "javascript",
    javascriptreact = "javascript",
    typescriptreact = "javascript",
    sh = "shell",
    bash = "shell",
    zsh = "shell",
  }
  local lang = map[ft]
  if not lang then
    return nil
  end

  local ok, mod = pcall(require, "appsec.languages." .. lang)
  return ok and mod or nil
end

-- Генератори для кожної мови (зберігають старі імена функцій для сумісності)
M.list_functions_step = function()
  local mod = get_lang_module("go")
  return mod and mod.list_functions_step() or function()
    return "ℹ️ Go module not found"
  end
end

M.list_python_functions_step = function()
  local mod = get_lang_module("python")
  return mod and mod.list_functions_step() or function()
    return "ℹ️ Python module not found"
  end
end

M.list_javascript_functions_step = function()
  local mod = get_lang_module("javascript")
  return mod and mod.list_functions_step() or function()
    return "ℹ️ JS/TS module not found"
  end
end

M.list_rust_functions_step = function()
  local mod = get_lang_module("rust")
  return mod and mod.list_functions_step() or function()
    return "ℹ️ Rust module not found"
  end
end

M.list_php_functions_step = function()
  local mod = get_lang_module("php")
  return mod and mod.list_functions_step() or function()
    return "ℹ️ PHP module not found"
  end
end

M.list_lua_functions_step = function()
  local mod = get_lang_module("lua")
  return mod and mod.list_functions_step() or function()
    return "ℹ️ Lua module not found"
  end
end

M.list_shell_functions_step = function()
  local mod = get_lang_module("shell")
  return mod and mod.list_functions_step() or function()
    return "ℹ️ Shell module not found"
  end
end

-- ============================================================================
-- 🔹 4. ІНШІ ХЕЛПЕРИ
-- ============================================================================
function M.get_install_hint(tool)
  return utils.get_install_hint(tool)
end
function M.get_language_config(ft)
  return M.config.languages[ft]
end
function M.is_supported(ft)
  local cfg = M.config.languages[ft]
  return cfg ~= nil and cfg.enabled == true
end

function M.pprof_step(func_name)
  return function()
    local cwd = vim.fn.getcwd()
    local target = func_name or "main"
    local cmd = string.format(
      "cd '%s' && go test -bench=%s -benchmem -cpuprofile=cpu.prof -memprofile=mem.prof ./... 2>&1",
      cwd,
      target
    )
    local output = vim.fn.system(cmd)
    return vim.v.shell_error == 0 and string.format("✅ pprof: saved (func: %s)", target)
      or string.format("⚠️ pprof error: %s", output:sub(1, 120))
  end
end

return M
