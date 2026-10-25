return {
  "mfussenegger/nvim-dap",
  dependencies = {
    -- "niuiic/dap-utils.nvim", -- Розкоментуйте, якщо dap-utils це окремий плагін
  },
  config = function()
    local dap = require("dap")
    local dap_utils = require("dap-utils")

    -- =====================================================================
    -- 1. Налаштування адаптера NLua (для дебагінгу самого Neovim)
    -- =====================================================================
    dap.adapters.nlua = function(callback, config)
      callback({
        type = "server",
        host = config.host or "127.0.0.1",
        port = config.port or 8086, -- Стандартний порт для NLua/OSV
      })
    end

    -- =====================================================================
    -- 2. Конфігурація запуску через dap-utils
    -- =====================================================================
    dap_utils.setup({
      lua = function(run)
        run({
          type = "nlua",
          request = "attach",
          name = "Attach to running Neovim instance",
        })
      end,
    })
  end,

  -- =====================================================================
  -- 3. Гарячі клавіші
  -- =====================================================================
  keys = {
    -- Запуск дебагу Lua (підключення до Neovim)
    {
      "<leader>dl",
      function()
        require("dap-utils").run("lua")
      end,
      desc = "🌙 Debug Lua (Attach to Neovim)",
    },
    
    -- Базові клавіші DAP (якщо вони не налаштовані глобально)
    { "<F5>", function() require("dap").continue() end, desc = "▶️ Continue" },
    { "<F10>", function() require("dap").step_over() end, desc = "➡️ Step Over" },
    { "<F11>", function() require("dap").step_into() end, desc = "⬇️ Step Into" },
    { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "🔴 Toggle Breakpoint" },
  },
}