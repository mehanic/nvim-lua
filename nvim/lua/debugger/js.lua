return {
  "mxsdev/nvim-dap-vscode-js", -- Плагін-міст для VS Code JS дебагера
  dependencies = {
    "mfussenegger/nvim-dap", -- Базовий DAP плагін (якщо він ще не підключений в іншому файлі)
    -- "ваш_шлях/dap-utils.nvim", -- Розкоментуйте, якщо dap-utils це окремий плагін
  },
  config = function()
    local dap = require("dap")
    local dap_utils = require("dap-utils")

    -- =====================================================================
    -- 1. Налаштування самого плагіна dap-vscode-js
    -- =====================================================================
    ---@diagnostic disable-next-line: missing-fields
    require("dap-vscode-js").setup({
      debugger_cmd = { os.getenv("HOME") .. "/.local/share/nvim/mason/bin/js-debug-adapter" },
    })

    -- =====================================================================
    -- 2. Реєстрація адаптерів для Node.js та Chrome
    -- =====================================================================
    local function set_adapter(adapter)
      dap.adapters[adapter] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            os.getenv("HOME")
              .. "/.local/share/nvim/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
            "${port}",
          },
        },
      }
    end

    local adapters = { "pwa-node", "pwa-chrome" }
    for _, adapter in ipairs(adapters) do
      set_adapter(adapter)
    end

    -- =====================================================================
    -- 3. Конфігурації запуску (Node, Deno, Browser)
    -- =====================================================================
    local function get_node()
      local cwd = vim.fs.root(0, "package.json") or vim.fn.getcwd()
      return {
        {
          name = "Launch project",
          type = "pwa-node",
          request = "launch",
          cwd = cwd,
          runtimeExecutable = "pnpm",
          runtimeArgs = { "debug" },
        },
        {
          name = "Launch file",
          type = "pwa-node",
          request = "launch",
          program = "${file}",
          cwd = cwd,
        },
        {
          name = "Attach",
          type = "pwa-node",
          request = "attach",
          port = 9229,
          cwd = cwd,
        },
        {
          name = "Attach process",
          type = "pwa-node",
          request = "attach",
          processId = require("dap.utils").pick_process,
          cwd = cwd,
        },
      }
    end

    local function get_deno()
      local cwd = vim.fs.root(0, "package.json") or vim.fn.getcwd()
      return {
        name = "Deno",
        type = "pwa-node",
        request = "launch",
        program = "${file}",
        runtimeExecutable = "deno",
        runtimeArgs = { "--inspect-wait" },
        cwd = cwd,
        attachSimplePort = 9229,
      }
    end

    local function get_browser()
      local cwd = vim.fs.root(0, "package.json") or vim.fn.getcwd()
      return {
        {
          name = "Launch Chrome",
          type = "pwa-chrome",
          request = "launch",
          runtimeExecutable = "/usr/bin/google-chrome-stable", -- ⚠️ Перевірте шлях до Chrome!
          userDataDir = false,
          webRoot = cwd,
        },
        {
          name = "attach chrome",
          type = "pwa-chrome",
          request = "attach",
          port = 9222,
          webroot = cwd,
        },
      }
    end

    -- Допоміжна функція для перевірки Vue (вимагає вашого кастомного модуля omega)
    local function is_vue_project()
      local ok, omega = pcall(require, "omega")
      if not ok then return false end
      return omega.exist_in_file("vue", (vim.fs.root(0, ".git") or vim.fn.getcwd()) .. "/package.json")
    end

    -- Допоміжна функція для перевірки Deno (вимагає вашого кастомного модуля tools)
    local function is_deno_project()
      local ok, tools = pcall(require, "tools")
      if not ok then return false end
      return tools.is_deno_project()
    end

    -- =====================================================================
    -- 4. Прив'язка мов до конфігурацій через dap-utils
    -- =====================================================================
    dap_utils.setup({
      typescript = function(run)
        if is_deno_project() then
          run(get_deno())
        elseif is_vue_project() then
          run(vim.list_extend(get_browser(), get_node()))
        else
          run(get_node())
        end
      end,
      javascript = function(run)
        if is_deno_project() then
          run(get_deno())
        elseif is_vue_project() then
          run(vim.list_extend(get_browser(), get_node()))
        else
          run(get_node())
        end
      end,
      javascriptreact = function(run)
        run(get_browser())
      end,
      typescriptreact = function(run)
        run(get_browser())
      end,
      vue = function(run)
        run(get_browser())
      end,
    })
  end,
}