return {
  "mfussenegger/nvim-dap", -- Основний плагін для відладки
  dependencies = {
    "niuiic/dap-utils.nvim", -- Плагін dap-utils (якщо це ваш локальний модуль, видаліть цей рядок)
    
    -- 🎨 Рекомендовано: UI для дебагера (вікна зі змінними, стеком тощо)
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "nvim-neotest/nvim-nio",
    },
  },
  
  config = function()
    local dap = require("dap")
    local dap_utils = require("dap-utils")

    -- =====================================================================
    -- 1. Налаштування адаптера Python (ваш код)
    -- =====================================================================
    dap.adapters.python = function(cb, config)
      if config.request == "attach" then
        ---@diagnostic disable-next-line: undefined-field
        local port = (config.connect or config).port
        ---@diagnostic disable-next-line: undefined-field
        local host = (config.connect or config).host or "127.0.0.1"
        cb({
          type = "server",
          port = assert(port, "`connect.port` is required for a python `attach` configuration"),
          host = host,
          options = {
            source_filetype = "python",
          },
        })
      else
        cb({
          type = "executable",
          -- ⚠️ Важливо: цей шлях вимагає, щоб debugpy був встановлений через Mason!
          command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
          args = { "-m", "debugpy.adapter" },
          options = {
            source_filetype = "python",
          },
        })
      end
    end

    -- =====================================================================
    -- 2. Налаштування конфігурацій запуску (ваш код)
    -- =====================================================================
    dap_utils.setup({
      python = function(run)
        run({
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            local cwd = vim.fn.getcwd()
            if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
              return cwd .. "/venv/bin/python"
            elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
              return cwd .. "/.venv/bin/python"
            else
              return "/usr/bin/python"
            end
          end,
        })
      end,
    })

    -- =====================================================================
    -- 3. Налаштування DAP UI (візуальне оформлення)
    -- =====================================================================
    local dapui = require("dapui")
    dapui.setup({
      icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
      mappings = {
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
      },
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.33 },
            { id = "breakpoints", size = 0.17 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = 40,
          position = "right",
        },
        {
          elements = {
            { id = "repl", size = 0.45 },
            { id = "console", size = 0.55 },
          },
          size = 10,
          position = "bottom",
        },
      },
    })

    -- Автоматичне відкриття/закриття UI при старті/зупинці дебагу
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end
  end,

  -- =====================================================================
  -- 4. Гарячі клавіші для керування відладкою
  -- =====================================================================
  keys = {
    -- Основні дії
    { "<F5>", function() require("dap").continue() end, desc = " Continue (F5)" },
    { "<F10>", function() require("dap").step_over() end, desc = " Step Over (F10)" },
    { "<F11>", function() require("dap").step_into() end, desc = " Step Into (F11)" },
    { "<F12>", function() require("dap").step_out() end, desc = "⬆ Step Out (F12)" },
    
    -- Брейкпоінти
    { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "🔴 Toggle Breakpoint (F9)" },
    { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Breakpoint Condition" },
    
    -- Запуск через dap-utils (ваша кастомна логіка)
    { "<leader>dr", function() require("dap-utils").run("python") end, desc = "🐍 Run Python (dap-utils)" },
    
    -- UI
    { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
    { "<leader>de", function() require("dapui").eval() end, desc = "Eval expression", mode = {"n", "v"} },
  },
}