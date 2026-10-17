-- ========================================================================
-- 🔐 APPSEC SMART PIPELINE
-- ========================================================================

-- Завантаження Pipeline модуля
local Pipeline = _G.Pipeline or require("pipeline")
_G.Pipeline = Pipeline

-- Хелпер для TruffleHog
local function trufflehog_wrapper()
  return function()
    if vim.fn.executable("trufflehog") ~= 1 then
      return "⚠️ TruffleHog not found"
    end
    local cmd = "trufflehog filesystem . --results=verified,unknown --json --no-update 2>&1"
    local result = vim.fn.system(cmd)
    local exit_code = vim.v.shell_error
    if exit_code == 183 then
      return "🔐 Secrets found — check output"
    elseif exit_code ~= 0 then
      return string.format("⚠️ TruffleHog warning (code %d)", exit_code)
    end
    return "✅ No secrets found"
  end
end

-- Хелпер для shell-команд
local function shell_step(cmd)
  return function()
    local result = vim.fn.system(cmd)
    local exit_code = vim.v.shell_error
    if exit_code == 0 then
      return "✅ OK"
    else
      return string.format("⚠️ Warning: %s", result:sub(1, 150))
    end
  end
end

-- Головна команда SmartPipeline
vim.api.nvim_create_user_command("SmartPipeline", function()
  local Pipeline = _G.Pipeline

  if not Pipeline or type(Pipeline.new) ~= "function" then
    vim.notify("❌ Pipeline module not loaded!", vim.log.levels.ERROR)
    return
  end

  local ft = vim.bo.filetype
  local cwd = vim.fn.getcwd()
  local pipe

  -- 🔹 Go
  if ft == "go" or vim.fn.filereadable(cwd .. "/go.mod") == 1 then
    local go_root = cwd
    local mod_path = vim.fn.system("go env GOMOD 2>/dev/null"):gsub("%s+$", "")

    if mod_path ~= "" and mod_path ~= "/dev/null" and vim.fn.filereadable(mod_path) == 1 then
      go_root = vim.fn.fnamemodify(mod_path, ":h")
    end

    local cd = string.format("cd '%s' && ", go_root)

    pipe = Pipeline.new("🐹 Go + 🛡️ Security", {
      { name = "1️ gofmt", cmd = cd .. "gofmt -l -e . 2>&1", ignore_errors = true },
      { name = "2️⃣ go mod tidy", cmd = cd .. "go mod tidy", ignore_errors = true },
      { name = "3️⃣ go vet", cmd = cd .. "go vet ./...", ignore_errors = true },
      { name = "4️⃣ go test", cmd = cd .. "go test -short ./...", ignore_errors = true },
      {
        name = "📋 Function List",
        fn = require("appsec.static_analyzer").list_functions_step(),
        ignore_errors = true,
        timeout_ms = 10000,
      },
      {
        name = "📊 Static Analyzer",
        fn = function()
          return require("appsec.static_analyzer").analyze_sync(ft, go_root)
        end,
        ignore_errors = true,
        timeout_ms = 300000,
      },
      {
        name = "🔐 TruffleHog",
        fn = function()
          if vim.fn.executable("trufflehog") ~= 1 then
            return "⚠️ TruffleHog not found"
          end
          local res = vim.fn.system(cd .. "trufflehog filesystem . --results=verified,unknown --json --no-update 2>&1")
          local code = vim.v.shell_error
          if code == 183 then
            return "🔐 Secrets found — check output"
          elseif code ~= 0 then
            return string.format("⚠️ Warning (code %d)", code)
          else
            return "✅ No secrets found"
          end
        end,
        ignore_errors = true,
      },
      {
        name = "🔍 gosec [Balanced]",
        fn = function()
          if vim.fn.executable("gosec") ~= 1 then
            return "⚠️ gosec not in PATH"
          end

          local root = vim.fn.system("go env GOMOD 2>/dev/null | xargs dirname 2>/dev/null || echo ."):gsub("%s+$", "")

          local include_rules = table.concat({
            "G201",
            "G202",
            "G203",
            "G204",
            "G401",
            "G402",
            "G403",
            "G404",
            "G101",
            "G102",
            "G106",
            "G107",
            "G304",
            "G108",
          }, ",")

          local exclude_rules = table.concat({
            "G104",
            "G307",
            "G601",
          }, ",")

          local cmd = string.format(
            "cd '%s' && gosec -quiet -fmt=json -no-fail -include=%s -exclude=%s -exclude-dir=vendor,_test ./... 2>/dev/null || echo '{}'",
            root,
            include_rules,
            exclude_rules
          )

          local res = vim.fn.system(cmd)
          return vim.v.shell_error == 0 and "✅ gosec: OK" or string.format("⚠️ gosec: %s", res:sub(1, 150))
        end,
        ignore_errors = true,
      },
      {
        name = "🧬 govulncheck",
        fn = function()
          if vim.fn.executable("govulncheck") ~= 1 then
            return "ℹ️ govulncheck not installed"
          end
          local old_cwd = vim.loop.cwd()
          local root = vim.fn.system("go env GOMOD 2>/dev/null | xargs dirname 2>/dev/null || echo ."):gsub("%s+$", "")
          if root == "" or root == "." then
            root = old_cwd
          end

          vim.loop.chdir(root)
          local res = vim.fn.system("govulncheck ./... 2>&1 || echo 'ℹ️ govulncheck finished'")
          vim.loop.chdir(old_cwd)

          return vim.v.shell_error == 0 and "✅ govulncheck: OK"
            or string.format("️ govulncheck: %s", res:sub(1, 120))
        end,
        ignore_errors = true,
      },
      {
        name = "🐳 Trivy (App/Filesystem)",
        cmd = "trivy fs --scanners vuln,secret --exit-code 0 . 2>/dev/null || echo '️ Trivy not installed'",
        ignore_errors = true,
        timeout_ms = 120000,
        when = function()
          return vim.fn.executable("trivy") == 1
        end,
      },
      {
        name = "️ Checkov (IaC: Terraform/K8s)",
        cmd = "checkov -d . --quiet --compact --framework terraform,kubernetes,secrets 2>/dev/null || echo 'ℹ️ Checkov not installed'",
        ignore_errors = true,
        timeout_ms = 90000,
        when = function()
          return vim.fn.filereadable("main.tf") == 1
            or vim.fn.filereadable("k8s.yaml") == 1
            or vim.fn.filereadable("Chart.yaml") == 1
        end,
      },
      {
        name = "📋 SBOM (Syft)",
        cmd = "syft . -o cyclonedx-json > sbom.json 2>/dev/null || echo '️ Syft not found'",
        ignore_errors = true,
        when = function()
          return vim.fn.executable("syft") == 1
        end,
      },
    })

  -- 🔹 Python
  elseif ft == "python" or vim.fn.filereadable(cwd .. "/pyproject.toml") == 1 then
    pipe = Pipeline.new("🐍 Python + 🛡️ Security", {
      { name = "1️⃣ ruff fix", cmd = "ruff check . --fix", ignore_errors = true },
      { name = "2️⃣ ruff fmt", cmd = "ruff format .", ignore_errors = true },
      {
        name = "3️⃣ mypy",
        cmd = "mypy . --ignore-missing-imports --follow-imports=silent 2>/dev/null || echo 'ℹ️ mypy skipped'",
        ignore_errors = true,
      },
      {
        name = "4️⃣ pytest",
        cmd = "pytest -q --collect-only 2>/dev/null | grep -q 'collected' && pytest -q || echo 'ℹ️ No tests found'",
        ignore_errors = true,
      },
      {
        name = "📋 Python Function List",
        fn = require("appsec.static_analyzer").list_python_functions_step(),
        ignore_errors = true,
        timeout_ms = 10000,
      },
      {
        name = "📊 Static Analyzer",
        fn = function()
          return require("appsec.static_analyzer").analyze_sync(ft, cwd)
        end,
        ignore_errors = true,
        timeout_ms = 300000,
      },
      {
        name = "🔐 TruffleHog",
        fn = Pipeline.trufflehog_step("filesystem", ".", {
          results = "verified,unknown",
          fail_on_find = false,
          json_output = true,
          timeout_ms = 90000,
          auto_install = false,
        }),
        ignore_errors = true,
      },
      {
        name = "🔍 bandit",
        cmd = "bandit -r . -q -f json --exclude '*/venv/*,*/__pycache__/*,*/.git/*' 2>/dev/null || echo '{}'",
        ignore_errors = true,
        when = function()
          return vim.fn.executable("bandit") == 1
        end,
      },
      {
        name = "🧬 pip-audit",
        cmd = "pip-audit --format=json 2>/dev/null || echo '{}'",
        ignore_errors = true,
        when = function()
          return vim.fn.executable("pip-audit") == 1
            and (vim.env.VIRTUAL_ENV ~= nil or vim.fn.filereadable(cwd .. "/pyproject.toml") == 1)
        end,
      },
    })

  -- 🔹 PHP
  elseif
    ft == "php"
    or vim.fn.filereadable(cwd .. "/phpunit.xml") == 1
    or vim.fn.filereadable(cwd .. "/composer.json") == 1
  then
    pipe = Pipeline.new(" PHP + 🛡️ Security", {
      {
        name = "1️⃣ php-cs-fixer",
        cmd = "php-cs-fixer fix --dry-run --diff",
        ignore_errors = true,
        when = function()
          return vim.fn.executable("php-cs-fixer") == 1
        end,
      },
      {
        name = "2️⃣ phpstan",
        cmd = "phpstan analyse --level=5 --no-progress src/",
        ignore_errors = true,
        when = function()
          return vim.fn.executable("phpstan") == 1
        end,
      },
      {
        name = "3️⃣ phpunit",
        cmd = "phpunit --no-coverage --stop-on-failure",
        ignore_errors = true,
        when = function()
          return vim.fn.filereadable(cwd .. "/phpunit.xml") == 1 or vim.fn.filereadable(cwd .. "/phpunit.dist.xml") == 1
        end,
      },
      {
        name = "📋 PHP Function List",
        fn = require("appsec.static_analyzer").list_php_functions_step(),
        ignore_errors = true,
        timeout_ms = 10000,
      },
      {
        name = " Static Analyzer",
        fn = function()
          return require("appsec.static_analyzer").analyze_sync(ft, cwd)
        end,
        ignore_errors = true,
        timeout_ms = 300000,
      },
      {
        name = "🔐 TruffleHog",
        fn = Pipeline.trufflehog_step("filesystem", ".", {
          results = "verified,unknown",
          fail_on_find = false,
          timeout_ms = 90000,
          auto_install = false,
        }),
        ignore_errors = true,
      },
      {
        name = "🔍 semgrep (SAST)",
        cmd = "semgrep --config=auto --quiet --json . 2>/dev/null || echo '{}'",
        ignore_errors = true,
        when = function()
          return vim.fn.executable("semgrep") == 1
        end,
      },
      {
        name = "🧬 composer audit",
        cmd = "composer audit --format=json 2>/dev/null || echo '{}'",
        ignore_errors = true,
        when = function()
          return vim.fn.executable("composer") == 1
        end,
      },
    })

  -- 🔹 Rust
  elseif ft == "rust" or vim.fn.filereadable(cwd .. "/Cargo.toml") == 1 then
    local rust_root = vim.fs and vim.fs.root(0, { "Cargo.toml" }) or cwd
    local is_project = vim.fn.filereadable(rust_root .. "/Cargo.toml") == 1
    local cd = is_project and string.format("cd '%s' && ", rust_root) or ""

    pipe = Pipeline.new("🦀 Rust + ️ Security", {
      {
        name = "1️⃣ rustfmt",
        cmd = is_project and (cd .. "cargo fmt") or string.format("rustfmt --edition 2021 '%s'", vim.fn.expand("%:p")),
        ignore_errors = true,
      },
      {
        name = "2️⃣ cargo check",
        cmd = cd .. "cargo check --all-targets",
        ignore_errors = true,
        when = function()
          return is_project
        end,
      },
      {
        name = "3️⃣ cargo clippy",
        cmd = cd .. "cargo clippy -- -D warnings",
        ignore_errors = true,
        when = function()
          return is_project
        end,
      },
      {
        name = "4️⃣ cargo test",
        cmd = cd .. "cargo test --quiet",
        ignore_errors = true,
        when = function()
          return is_project
        end,
      },
      {
        name = " Rust Function List",
        fn = require("appsec.static_analyzer").list_rust_functions_step(),
        ignore_errors = true,
        timeout_ms = 10000,
      },
      {
        name = "🔐 TruffleHog",
        fn = Pipeline.trufflehog_step("filesystem", ".", {
          results = "verified,unknown",
          fail_on_find = false,
          json_output = true,
          timeout_ms = 90000,
          auto_install = false,
        }),
        ignore_errors = true,
      },
      {
        name = "🧬 cargo-audit",
        cmd = cd .. "cargo audit --quiet --json 2>/dev/null || echo '{}'",
        ignore_errors = true,
        when = function()
          return vim.fn.executable("cargo-audit") == 1 and is_project
        end,
      },
    })

  -- 🔹 JS/TS
  elseif ft:match("^javascript") or ft:match("^typescript") or vim.fn.filereadable(cwd .. "/package.json") == 1 then
    local test_cmd = "npm test"
    if vim.fn.filereadable(cwd .. "/jest.config.js") == 1 or vim.fn.filereadable(cwd .. "/jest.config.ts") == 1 then
      test_cmd = "npx jest --passWithNoTests"
    elseif vim.fn.filereadable(cwd .. "/vitest.config.ts") == 1 then
      test_cmd = "npx vitest run --passWithNoTests"
    end

    pipe = Pipeline.new("🌐 JS/TS + 🛡️ Security", {
      {
        name = "1️⃣ prettier",
        cmd = "npx prettier --write . --ignore-unknown",
        timeout_ms = 60000,
        ignore_errors = true,
      },
      { name = "2️⃣ eslint", cmd = "npx eslint . --fix --quiet", ignore_errors = true, timeout_ms = 60000 },
      {
        name = "3️⃣ tsc",
        cmd = "npx tsc --noEmit",
        ignore_errors = true,
        when = function()
          return ft:match("^typescript")
        end,
      },
      { name = "4️⃣ test", cmd = test_cmd, timeout_ms = 120000, ignore_errors = true },
      {
        name = "🟨 JS/TS Function List",
        fn = require("appsec.static_analyzer").list_javascript_functions_step(),
        ignore_errors = true,
        timeout_ms = 10000,
      },
      {
        name = "🔐 TruffleHog",
        fn = Pipeline.trufflehog_step("filesystem", ".", {
          results = "verified,unknown",
          fail_on_find = false,
          json_output = true,
          timeout_ms = 90000,
          auto_install = false,
        }),
        ignore_errors = true,
      },
      {
        name = " semgrep",
        cmd = "npx semgrep --config=auto --quiet --json . 2>/dev/null || echo '{}'",
        ignore_errors = true,
        timeout_ms = 120000,
        when = function()
          return vim.fn.executable("npx") == 1
        end,
      },
      {
        name = " npm audit",
        cmd = "npm audit --json 2>/dev/null || echo '{}'",
        ignore_errors = true,
        timeout_ms = 60000,
        when = function()
          return vim.fn.filereadable(cwd .. "/package-lock.json") == 1
        end,
      },
    })

  -- 🔹 Lua
  elseif
    ft == "lua"
    or vim.fn.filereadable(cwd .. "/init.lua") == 1
    or vim.fn.filereadable(cwd .. "/.luarc.json") == 1
  then
    pipe = Pipeline.new("🌙 Lua + 🛡️ Security", {
      {
        name = "1️ stylua",
        cmd = "stylua --check . 2>/dev/null || echo 'ℹ️ stylua: skipped or no files'",
        ignore_errors = true,
        when = function()
          return vim.fn.executable("stylua") == 1
        end,
      },
      {
        name = "2️⃣ luacheck",
        cmd = "luacheck . --quiet 2>/dev/null || echo 'ℹ️ luacheck: skipped'",
        ignore_errors = true,
        when = function()
          return vim.fn.executable("luacheck") == 1
        end,
      },
      {
        name = "3️⃣ luac syntax",
        cmd = "find . -name '*.lua' -exec luac -p {} \\; 2>/dev/null || echo 'ℹ️ Syntax OK'",
        ignore_errors = true,
      },
      {
        name = "🌙 Lua Function List",
        fn = require("appsec.static_analyzer").list_lua_functions_step(),
        ignore_errors = true,
        timeout_ms = 10000,
      },
      {
        name = "🔐 TruffleHog",
        fn = Pipeline.trufflehog_step("filesystem", ".", {
          results = "verified,unknown",
          fail_on_find = false,
          json_output = true,
          timeout_ms = 90000,
          auto_install = false,
        }),
        ignore_errors = true,
      },
      {
        name = "🔍 semgrep (Lua)",
        cmd = "semgrep --config=auto --lang lua --quiet --json . 2>/dev/null || echo '{}'",
        ignore_errors = true,
        timeout_ms = 120000,
        when = function()
          return vim.fn.executable("semgrep") == 1
        end,
      },
    })

  -- 🔹 Bash/Shell
  elseif
    ft == "sh"
    or ft == "bash"
    or ft == "zsh"
    or vim.fn.filereadable(cwd .. "/.bashrc") == 1
    or vim.fn.filereadable(cwd .. "/.zshrc") == 1
  then
    pipe = Pipeline.new("🐚 Bash/Shell + ️ Security", {
      {
        name = "1️⃣ shfmt",
        cmd = "shfmt -l -w -i 2 -sr . 2>/dev/null || echo 'ℹ️ shfmt: skipped or no files'",
        ignore_errors = true,
      },
      {
        name = "2️⃣ shellcheck",
        cmd = "shellcheck -f gcc -x -S warning . 2>/dev/null || echo 'ℹ️ shellcheck skipped'",
        ignore_errors = true,
      },
      {
        name = "3️⃣ syntax",
        cmd = "find . -type f \\( -name '*.sh' -o -name '*.bash' -o -name '*.zsh' \\) -exec bash -n {} \\; 2>/dev/null || echo 'ℹ️ Syntax OK'",
        ignore_errors = true,
      },
      {
        name = "4️ bats test",
        cmd = "bats --tap . 2>/dev/null || echo 'ℹ️ No Bats tests found'",
        ignore_errors = true,
        timeout_ms = 120000,
      },
      {
        name = "🐚 Shell Function List",
        fn = require("appsec.static_analyzer").list_shell_functions_step(),
        ignore_errors = true,
        timeout_ms = 10000,
      },
      {
        name = "🔐 TruffleHog",
        fn = Pipeline.trufflehog_step("filesystem", ".", {
          results = "verified,unknown",
          fail_on_find = false,
          json_output = true,
          timeout_ms = 90000,
          auto_install = false,
        }),
        ignore_errors = true,
      },
      {
        name = "🔍 semgrep (Shell)",
        cmd = vim.fn.executable("semgrep") == 1 and "semgrep --config=auto --json --quiet . 2>/dev/null || echo '{}'"
          or "npx semgrep --config=auto --json --quiet . 2>/dev/null || echo '{}'",
        ignore_errors = true,
        timeout_ms = 120000,
        when = function()
          return vim.fn.executable("semgrep") == 1 or vim.fn.executable("npx") == 1
        end,
      },
    })

  -- 🔹 Fallback
  else
    pipe = Pipeline.new("Unknown", {
      {
        name = "ℹ️ Info",
        fn = function()
          vim.notify(
            "❓ Не знайдено відомий тип проєкту (go.mod / pyproject.toml / Cargo.toml / package.json)",
            vim.log.levels.WARN
          )
        end,
      },
    })
  end

  pipe:run()
end, { desc = "🔄 Розумний пайплайн (автодетект: Go/Py/PHP/Rust/JS/TS)" })

-- Клавіша для швидкого запуску
vim.keymap.set("n", "<leader>pr", ":SmartPipeline<CR>", { desc = "🔄 Run Smart Pipeline" })
