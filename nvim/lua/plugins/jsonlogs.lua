return {
  "ll931217/jsonlogs.nvim",
  ft = "jsonl", -- Ліниве завантаження тільки для .jsonl файлів
  opts = {
    -- =============================================
    -- 🔹 BASIC OPTIONS
    -- =============================================
    prefix = "<leader>jl",
    auto_open = false, -- ⚠️ Вимкнено: керуємо вручну через autocmd (див. config нижче)

    -- =============================================
    -- 🔹 PANEL LAYOUT
    -- =============================================
    layout = {
      position = "right", -- Панель прев'ю праворуч (як Aerial)
      width = 80, -- Ширина панелі прев'ю
      height = 20, -- Висота (якщо горизонтальний split)
    },

    -- =============================================
    -- 🔹 JSON FORMATTING
    -- =============================================
    json = {
      indent = 2, -- Відступи для pretty-print
      use_jq_fallback = true, -- 🔥 Використовувати jq для великих об'єктів (>10KB)
      jq_path = "jq", -- Шлях до jq (якщо не в PATH)
    },

    -- =============================================
    --  NAVIGATION (AppSec-оптимізовано)
    -- =============================================
    navigation = {
      error_field = "level", -- Поле для визначення рівня (level/severity)
      error_values = {
        "error",
        "ERROR",
        "fatal",
        "FATAL",
        "warn",
        "WARN",
        "warning",
        "WARNING",
        "high",
        "HIGH",
        "critical",
        "CRITICAL",
      },
    },

    -- =============================================
    -- 🔹 DISPLAY
    -- =============================================
    display = {
      show_line_numbers = true,
      syntax_highlighting = true,
      compact_fields = {
        "timestamp",
        "time",
        "ts",
        "level",
        "severity",
        "message",
        "msg",
        "details",
        "source",
        "rule",
        "rule_id",
      },
      table_max_col_width = 40, -- Трохи ширше для читабельності
      table_null_placeholder = "—",
      table_page_size = 50, -- 50 записів на сторінку
    },

    -- =============================================
    -- 🔹 ANALYSIS
    -- =============================================
    analysis = {
      timestamp_field = "timestamp", -- Або "time", "ts" залежно від формату
      timestamp_formats = {
        "%Y-%m-%dT%H:%M:%S", -- ISO 8601 без timezone
        "%Y-%m-%d %H:%M:%S", -- Стандартний формат БД
        "%Y-%m-%dT%H:%M:%S%z", -- ISO 8601 з timezone
        "iso8601", -- Повний ISO 8601
      },
    },

    -- =============================================
    -- 🔹 PERFORMANCE
    -- =============================================
    performance = {
      use_jq_for_tables = true, -- 🔥 Прискорює таблиці в 10+ разів
    },

    -- =============================================
    -- 🔹 ADVANCED
    -- =============================================
    advanced = {
      tail_update_interval = 100, -- Інтервал оновлення tail mode (мс)
      max_preview_size = 10000, -- Макс. розмір для pretty-print перед jq
      virtual_text = true, -- Показувати віртуальний текст (інфо про рядки)
    },

    -- =============================================
    -- 🔹 STREAMING MODE (для великих файлів 100MB-1GB)
    -- =============================================
    streaming = {
      enabled = "auto", -- Авто-режим для файлів > threshold_mb
      threshold_mb = 10, -- Поріг для авто-стримінгу (MB)
      chunk_size = 1000, -- Рядків за один чанк
      cache_size = 200, -- Макс. об'єктів в пам'яті (збільшено для плавності)
      table_sample_size = 1000, -- Вибірка для визначення колонок таблиці
      stats_sample_size = 10000, -- Вибірка для статистики
      show_progress = true, -- Показувати прогрес для довгих операцій
    },

    -- =============================================
    -- 🔹 KEYBINDINGS
    -- =============================================
    keys = {
      -- 🔹 Навігація
      quit = "q", -- Закрити viewer
      next_entry = "j", -- Наступний лог
      prev_entry = "k", -- Попередній лог
      first_entry = "gg", -- Перший запис
      last_entry = "G", -- Останній запис

      -- 🔹 Навігація по помилках
      next_error = "]e", -- Наступна помилка
      prev_error = "[e", -- Попередня помилка

      -- 🔹 Дії з прев'ю
      toggle_fold = "<CR>", -- Згорнути/розгорнути в прев'ю
      yank_json = "y", -- Скопіювати форматований JSON
      switch_pane = "<Tab>", -- Перемикання між панелями
      maximize_preview = "f", -- Розгорнути прев'ю на весь екран

      -- 🔹 Пошук та фільтрація
      search = "/", -- Пошук за значенням поля

      -- 🔹 Закладки
      bookmark = "m", -- Додати закладку
      list_bookmarks = "'", -- Список закладок

      --  Режими відображення
      compact_mode = "c", -- Компактний режим
      table_mode = "T", -- 🔥 Табличний режим (дуже зручно!)

      -- 🔹 Пагінація таблиці
      table_next_page = "]", -- Наступна сторінка
      table_prev_page = "[", -- Попередня сторінка
      table_first_page = "[[", -- Перша сторінка
      table_last_page = "]]", -- Остання сторінка

      -- 🔹 Функції таблиці
      table_columns = "C", -- Фільтр колонок
      inspect_cell = "<CR>", -- Перегляд повного вмісту комірки

      -- 🔹 Аналіз
      diff_view = "d", -- Diff з позначеним рядком
      tail_mode = "t", -- 🔥 Live tail mode (як tail -f)
      stats = "s", -- Статистика логів
    },
  },

  -- 🔹 Додаткові налаштування після завантаження плагіна
  config = function(_, opts)
    require("jsonlogs").setup(opts)

    -- ========================================================================
    -- 🔹 1. ПРИМУСОВЕ РОЗПІЗНАВАННЯ JSONL-ФАЙЛІВ
    -- ========================================================================
    vim.filetype.add({
      extension = {
        jsonl = "jsonl",
      },
      pattern = {
        ["%.jsonl$"] = "jsonl",
        ["%.jsonl%.gz$"] = "jsonl", -- Стиснуті логи
        ["*.log.json$"] = "jsonl", -- Альтернативне розширення
        ["*.logs$"] = "jsonl", -- Для деяких CI/CD систем
      },
    })

    -- ========================================================================
    -- 🔹 2. ЗАХИСТ: АВТО-ВІДКРИТТЯ ТІЛЬКИ ДЛЯ JSONL
    -- ========================================================================
    -- Вирішує проблему, коли плагін намагається відкрити Lua/Python/Go файли
    vim.api.nvim_create_autocmd("BufReadPost", {
      group = vim.api.nvim_create_augroup("JsonLogsAutoOpen", { clear = true }),
      callback = function()
        local ft = vim.bo.filetype
        local filename = vim.fn.expand("%:t")
        local fullpath = vim.fn.expand("%:p")

        -- Перевіряємо, чи це дійсно JSONL-файл
        local is_jsonl = ft == "jsonl"
          or filename:match("%.jsonl$")
          or filename:match("%.jsonl%.gz$")
          or filename:match("%.log%.json$")

        if is_jsonl then
          -- Перевіряємо, чи файл не порожній і не бінарний
          local filesize = vim.fn.getfsize(fullpath)
          if filesize > 0 and filesize < 1073741824 then -- < 1GB
            pcall(function()
              require("jsonlogs").open()
            end)
          end
        end
      end,
    })

    -- ========================================================================
    -- 🔹 3. ДОДАТКОВІ КОМАНДИ
    -- ========================================================================
    vim.api.nvim_create_user_command("JsonLogsTable", function()
      require("jsonlogs").open({ table_mode = true })
    end, { desc = "📊 Open JSONL in table mode" })

    vim.api.nvim_create_user_command("JsonLogsTail", function()
      require("jsonlogs").open({ tail_mode = true })
    end, { desc = " Open JSONL in tail mode" })

    vim.api.nvim_create_user_command("JsonLogsCompact", function()
      require("jsonlogs").open({ compact_mode = true })
    end, { desc = "📋 Open JSONL in compact mode" })

    -- ========================================================================
    -- 🔹 4. ГЛОБАЛЬНІ КЛАВІШІ (якщо плагін завантажений)
    -- ========================================================================
    vim.keymap.set("n", "<leader>jl", function()
      pcall(function()
        require("jsonlogs").open()
      end)
    end, { desc = "📜 Open JSONL viewer" })
  end,
}
