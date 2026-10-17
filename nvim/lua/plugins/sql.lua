return {
  -- ========================================================================
  -- 🔹 1. VIM-DADBOD (Ядро для роботи з базами даних)
  -- ========================================================================
  {
    "tpope/vim-dadbod",
    cmd = "DB",
  },

  -- ========================================================================
  -- 🔹 2. VIM-DADBOD-UI (Зручний графічний інтерфейс)
  -- ========================================================================
  {
    "kristijanhusak/vim-dadbod-ui",
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    dependencies = { "tpope/vim-dadbod" },
    keys = {
      { "<leader>D", "<cmd>DBUIToggle<CR>", desc = "️ Toggle DB UI" },
    },
    init = function()
      local data_path = vim.fn.stdpath("data")

      -- Налаштування UI
      vim.g.db_ui_auto_execute_table_helpers = 1
      vim.g.db_ui_save_location = data_path .. "/dadbod_ui"
      vim.g.db_ui_tmp_query_location = data_path .. "/dadbod_ui/tmp"
      vim.g.db_ui_show_database_icon = true
      vim.g.db_ui_use_nerd_fonts = true
      vim.g.db_ui_use_nvim_notify = true

      -- 🔒 БЕЗПЕКА: Не виконувати запити автоматично при збереженні
      vim.g.db_ui_execute_on_save = false
    end,
  },

  -- ========================================================================
  --  3. VIM-DADBOD-COMPLETION (БЕЗ nvim-cmp, через стандартний omnifunc)
  -- ========================================================================
  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = { "tpope/vim-dadbod" },
    ft = { "sql", "mysql", "plsql" },
    config = function()
      -- Налаштовуємо стандартний omnifunc для SQL-файлів
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          -- Вказуємо Neovim використовувати dadbod для автодоповнення
          vim.bo.omnifunc = "vim_dadbod_completion#omnifunc"

          -- 💡 ОПЦІОНАЛЬНО: Зручніша клавіша замість <C-x><C-o>
          -- Розкоментуйте, якщо хочете викликати автодоповнення через Ctrl+Space
          -- vim.keymap.set("i", "<C-Space>", function()
          --   vim.fn.feedkeys("\\<C-x>\\<C-o>")
          -- end, { buffer = true, desc = "DB Completion" })
        end,
      })
    end,
  },

  -- ========================================================================
  -- 🔹 4. TREESITTER ДЛЯ SQL (Підсвітка синтаксису)
  -- ========================================================================
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, "sql")
    end,
  },

  -- ========================================================================
  -- 🔹 5. ФОРМАТУВАННЯ ТА ЛІНТИНГ (Mason + Conform)
  -- ========================================================================
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, "sqlfluff")
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.sql = { "sqlfluff" }
      opts.formatters_by_ft.mysql = { "sqlfluff" }
      opts.formatters_by_ft.plsql = { "sqlfluff" }

      opts.formatters = opts.formatters or {}
      opts.formatters.sqlfluff = {
        args = { "format", "--dialect=ansi", "-" },
      }
    end,
  },

  -- ========================================================================
  -- 🔹 6. EDGY.NVIM ІНТЕГРАЦІЯ (Опціонально)
  -- ========================================================================
  {
    "folke/edgy.nvim",
    optional = true,
    opts = function(_, opts)
      opts.right = opts.right or {}
      table.insert(opts.right, {
        title = "️ Database",
        ft = "dbui",
        pinned = true,
        width = 0.3,
        open = function()
          vim.cmd("DBUI")
        end,
      })

      opts.bottom = opts.bottom or {}
      table.insert(opts.bottom, {
        title = " DB Query Result",
        ft = "dbout",
      })
    end,
  },
}
