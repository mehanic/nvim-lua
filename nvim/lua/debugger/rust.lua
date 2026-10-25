return {
  "mfussenegger/nvim-dap",
  dependencies = {
    -- "ваш_шлях/dap-utils.nvim", -- Розкоментуйте, якщо dap-utils це окремий плагін
  },
  config = function()
    local dap = require("dap")
    local dap_utils = require("dap-utils")

    -- =====================================================================
    -- 1. Налаштування адаптера LLDB для Rust
    -- =====================================================================
    dap.adapters.lldb = {
      type = "executable",
      command = "/usr/bin/lldb-dap", -- ⚠️ Переконайтеся, що lldb-dap встановлений у системі!
      name = "lldb",
    }

    -- =====================================================================
    -- 2. Розумна конфігурація запуску Rust (ваш код)
    -- =====================================================================
    dap_utils.setup({
      rust = function(run)
        local config = {
          name = "Launch",
          type = "lldb",
          request = "launch",
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          initCommands = function()
            local rustc_sysroot = vim.fn.trim(vim.fn.system("rustc --print sysroot"))

            local script_import = 'command script import "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"'
            local commands_file = rustc_sysroot .. "/lib/rustlib/etc/lldb_commands"

            local commands = {}
            local file = io.open(commands_file, "r")
            if file then
              for line in file:lines() do
                table.insert(commands, line)
              end
              file:close()
            end
            table.insert(commands, 1, script_import)

            return commands
          end,
        }

        -- Збираємо проєкт перед запуском
        vim.cmd("!cargo build")

        local root_dir = vim.fs.root(0, ".git") or vim.fn.getcwd()
        local target_dir = root_dir .. "/target/debug/"

        if vim.uv.fs_stat(target_dir) then
          local executable = {}
          for path, path_type in vim.fs.dir(target_dir) do
            if path_type == "file" then
              local perm = vim.fn.getfperm(target_dir .. path)
              if perm and string.match(perm, "x", 3) then
                table.insert(executable, path)
              end
            end
          end

          if #executable == 1 then
            config.program = target_dir .. executable[1]
            run(config)
          elseif #executable > 1 then
            vim.ui.select(executable, { prompt = "Select executable" }, function(choice)
              if not choice then return end
              config.program = target_dir .. choice
              run(config)
            end)
          else
            vim.ui.input({ prompt = "Path to executable: ", default = root_dir .. "/target/debug/" }, function(input)
              if not input then return end
              config.program = input
              run(config)
            end)
          end
        else
          vim.ui.input({ prompt = "Path to executable: ", default = root_dir .. "/target/debug/" }, function(input)
            if not input then return end
            config.program = input
            run(config)
          end)
        end
      end,
    })
  end,

  -- =====================================================================
  -- 3. Гарячі клавіші (якщо вони не налаштовані глобально)
  -- =====================================================================
  keys = {
    { "<F5>", function() require("dap").continue() end, desc = "▶️ Continue" },
    { "<F10>", function() require("dap").step_over() end, desc = "➡️ Step Over" },
    { "<F11>", function() require("dap").step_into() end, desc = "⬇️ Step Into" },
    { "<F12>", function() require("dap").step_out() end, desc = "⬆️ Step Out" },
    { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "🔴 Toggle Breakpoint" },
    
    -- Запуск через dap-utils (якщо ваш dap-utils підтримує виклик по імені мови)
    { "<leader>dr", function() require("dap-utils").run("rust") end, desc = "🦀 Run Rust (dap-utils)" },
  },
}