return {
  "mfussenegger/nvim-dap",
  dependencies = {
    -- "niuiic/dap-utils.nvim", -- Розкоментуйте, якщо dap-utils це окремий плагін
  },
  config = function()
    local dap = require("dap")
    local dap_utils = require("dap-utils")

    -- =====================================================================
    -- 1. Налаштування адаптера BashDB (через Mason)
    -- =====================================================================
    dap.adapters.bashdb = {
      type = "executable",
      command = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/bash-debug-adapter",
      name = "bashdb",
    }

    -- =====================================================================
    -- 2. Конфігурація запуску через dap-utils
    -- =====================================================================
    dap_utils.setup({
      sh = function(run)
        run({
          type = "bashdb",
          request = "launch",
          name = "Launch file",
          showDebugOutput = true,
          pathBashdb = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
          pathBashdbLib = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir",
          trace = true,
          file = "${file}",
          program = "${file}",
          cwd = "${workspaceFolder}",
          pathCat = "cat",
          pathBash = "/bin/bash",
          pathMkfifo = "mkfifo",
          pathPkill = "pkill",
          args = {},
          env = {},
          terminalKind = "integrated",
        })
      end,
    })
  end,

  -- =====================================================================
  -- 3. Гарячі клавіші
  -- =====================================================================
  keys = {
    -- Запуск дебагу Bash/Shell
    {
      "<leader>db",
      function()
        require("dap-utils").run("sh")
      end,
      desc = "🐚 Debug Bash/Shell (dap-utils)",
    },
    
    -- Базові клавіші DAP (якщо вони не налаштовані глобально)
    { "<F5>", function() require("dap").continue() end, desc = "▶️ Continue" },
    { "<F10>", function() require("dap").step_over() end, desc = "️ Step Over" },
    { "<F11>", function() require("dap").step_into() end, desc = "⬇️ Step Into" },
    { "<F9>", function() require("dap").toggle_breakpoint() end, desc = " Toggle Breakpoint" },
  },
}