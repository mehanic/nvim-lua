return {
  "Isrothy/neominimap.nvim",
  version = "v3.*", -- Використовуємо стабільну гілку v3
  lazy = false, -- ⚠️ ВАЖЛИВО: НЕ ліниве завантаження (потрібен при старті)

  -- 🔹 Гарячі клавіші для керування мінімапою
  keys = {
    { "<leader>nt", "<cmd>Neominimap Toggle<cr>", desc = "🗺️ Minimap: toggle" },
    { "<leader>no", "<cmd>Neominimap Enable<cr>", desc = "🗺️ Minimap: enable" },
    { "<leader>nc", "<cmd>Neominimap Disable<cr>", desc = "🗺️ Minimap: disable" },
    { "<leader>nr", "<cmd>Neominimap Refresh<cr>", desc = "🗺️ Minimap: refresh" },
    { "<leader>nwt", "<cmd>Neominimap WinToggle<cr>", desc = "🗺️ Win: toggle" },
    { "<leader>nwr", "<cmd>Neominimap WinRefresh<cr>", desc = "🗺️ Win: refresh" },
    { "<leader>nf", "<cmd>Neominimap Focus<cr>", desc = "🗺️ Focus minimap" },
    { "<leader>nu", "<cmd>Neominimap Unfocus<cr>", desc = "🗺️ Unfocus minimap" },
    {
      "<leader>nd",
      function()
        local cfg = vim.g.neominimap or {}
        cfg.diagnostic = cfg.diagnostic or {}
        cfg.diagnostic.enabled = not cfg.diagnostic.enabled
        require("neominimap").refresh()
        vim.notify("Minimap diagnostics: " .. (cfg.diagnostic.enabled and "✅ ON" or "❌ OFF"), vim.log.levels.INFO)
      end,
      desc = "🗺️ Toggle diagnostics on minimap",
    },
  },

  -- 🔹 Ініціалізація налаштувань
  init = function()
    -- Рекомендовані опції для float-режиму
    vim.opt.wrap = false
    vim.opt.sidescrolloff = 36

    ---@type table
    vim.g.neominimap = {
      -- ✅ Автозапуск
      auto_enable = true,

      -- 🎨 Layout: float (сучасний, не займає місце)
      layout = "float",
      float = {
        minimap_width = 18, -- компактна ширина
        max_minimap_height = nil, -- без обмеження висоти
        margin = { right = 1, top = -1, bottom = 1 },
        z_index = 50, -- поверх інших плаваючих вікон
        window_border = "rounded", -- заокруглені краї (Nord-style)
        persist = true, -- відновлювати після закриття
      },

      -- 📐 Розмір "пікселя" мінімапи
      x_multiplier = 4, -- 4 символи коду = 1 точка по горизонталі
      y_multiplier = 1, -- 1 рядок = 1 точка по вертикалі

      -- 🎯 Позиція поточного рядка
      current_line_position = "center", -- фіксувати по центру вікна мінімапи

      -- ⏱ Затримка оновлення (продуктивність)
      delay = 150, -- швидше, ніж дефолтні 200мс

      -- 🔄 Синхронізація курсору
      sync_cursor = true,

      -- 🖱️ Клік по мінімапі
      click = {
        enabled = true,
        auto_switch_focus = true, -- автоматично фокусувати вікно після кліку
      },

      -- 🚫 Виключення
      exclude_filetypes = {
        "help",
        "bigfile",
        "neo-tree",
        "TelescopePrompt",
        "oil",
        "aerial",
        "dropbar_menu",
        "NvimTree",
        "snacks_picker",
      },
      exclude_buftypes = {
        "nofile",
        "nowrite",
        "quickfix",
        "terminal",
        "prompt",
      },

      -- 🔍 Діагностика (інтеграція з LSP + Security-фільтр)
      diagnostic = {
        enabled = true,
        severity = { min = vim.diagnostic.severity.HINT }, -- показуємо ВСІ рівні
        mode = "line", -- підсвічувати рядок, а не іконку
        priority = {
          ERROR = 200, -- 🔴 CRITICAL/HIGH вразливості
          WARN = 150, -- 🟡 MEDIUM ризики
          INFO = 100, -- 🔵 LOW/інформаційні
          HINT = 50, -- ⚪ підказки/аудит
        },
        icon = {
          ERROR = "🔴 ", -- SQLi, XSS, RCE, Auth bypass
          WARN = "🟡 ", -- Weak crypto, hardcoded secrets
          INFO = "🔵 ", -- Security headers, validation
          HINT = "⚪ ", -- Needs review
        },
        -- 🔹 Фільтр: показувати ТІЛЬКИ security-діагностику
        filter = function(diagnostic)
          if not diagnostic.source then
            return true
          end
          local sec_sources = {
            "gosec",
            "bandit",
            "semgrep",
            "trivy",
            "gitleaks",
            "checkov",
            "tfsec",
            "kube-linter",
          }
          -- Безпечна перевірка (сумісна з Neovim 0.9+)
          local contains = vim.list_contains or vim.tbl_contains
          return contains(sec_sources, diagnostic.source)
        end,
      },

      -- 🌳 Treesitter (підсвітка структури коду)
      treesitter = {
        enabled = true,
        priority = 200, -- вищий пріоритет, ніж у діагностики
      },

      -- 🌲 Git інтеграція (gitsigns.nvim)
      git = {
        enabled = true,
        mode = "sign", -- показувати + / ~ / - у sign column
        priority = 10,
        icon = {
          add = "│ ",
          change = "│ ",
          delete = "‾ ",
        },
      },

      -- 🔎 Пошук (опціонально)
      search = {
        enabled = false,
        mode = "line",
        priority = 20,
        icon = " ",
      },

      -- 🏷️ Marks (закладки)
      mark = {
        enabled = false,
        mode = "icon",
        priority = 15,
        show_builtins = false,
      },

      -- 📁 Fold інтеграція
      fold = {
        enabled = true,
      },

      -- 🎨 Власні highlight-групи (Nord-палітра)
      winopt = function(opt, winid)
        opt.winhighlight = table.concat({
          "Normal:NeominimapBackground",
          "FloatBorder:NeominimapBorder",
          "CursorLine:NeominimapCursorLine",
          "CursorLineNr:NeominimapCursorLineNr",
        }, ",")
        opt.wrap = false
        opt.foldcolumn = "0"
        opt.signcolumn = "auto:2"
        opt.number = false
        opt.relativenumber = false
        opt.scrolloff = 99999 -- фіксувати курсор по центру
        opt.sidescrolloff = 0
        opt.winblend = 10 -- легка прозорість
        opt.cursorline = true
        opt.spell = false
        opt.list = false
        opt.fillchars = "eob: "
        opt.winfixwidth = true
      end,
    }
  end,
}
