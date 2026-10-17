return {
  "stevearc/aerial.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  -- 🔹 Ліниве завантаження за командою або клавішею
  cmd = {
    "AerialToggle",
    "AerialOpen",
    "AerialClose",
    "AerialOpenAll",
    "AerialCloseAll",
    "AerialNext",
    "AerialPrev",
    "AerialGo",
    "AerialInfo",
    "AerialNavToggle",
  },
  keys = {
    { "<leader>a", "<cmd>AerialToggle!<CR>", desc = "🗂️ Aerial: toggle structure" },
    { "<leader>aa", "<cmd>AerialOpen<CR>", desc = "🗂️ Aerial: open" },
    { "<leader>ac", "<cmd>AerialClose<CR>", desc = "🗂️ Aerial: close" },
  },

  -- ========================================================================
  -- 🔹 ОСНОВНІ НАЛАШТУВАННЯ (OPTS)
  -- ========================================================================
  opts = function()
    return {
      --  1. БЕКЕНДИ (без пріоритетів мов, стандартний фолбек)
      backends = { "treesitter", "lsp", "markdown", "asciidoc", "man" },

      -- 🔹 Розширена фільтрація символів (однакова для всіх мов)
      filter_kind = {
        "Class",
        "Constructor",
        "Enum",
        "Function",
        "Interface",
        "Module",
        "Method",
        "Struct",
        "Field",
        "Variable",
        "Constant",
        "Property",
        "Event",
        "Operator",
        "TypeParameter",
        "Package",
        "Namespace",
        "Trait",
        "Key",
        "File",
        "Array",
      },

      -- 🔹 2. НАЛАШТУВАННЯ ВІКНА (LAYOUT)
      layout = {
        max_width = { 50, 0.25 },
        width = nil,
        min_width = 20,
        min_height = { 10, 0.1 },
        height = nil,
        max_height = 0.9,
        default_direction = "prefer_right",
        placement = "window",
        resize_to_content = true,
        resize_to_content_max_width = 60,
        preserve_equality = false,
        win_opts = {
          winhighlight = "Normal:AerialNormal,CursorLine:AerialCursorLine",
          cursorline = true,
          cursorcolumn = false,
          signcolumn = "no",
          foldcolumn = "0",
          list = false,
        },
      },

      attach_mode = "window",
      close_automatic_events = { "unsupported" },

      --  3. ІКОНКИ (З АДАПТАЦІЄЮ ПІД PYTHON)
      nerd_font = "auto",
      icons = {
        -- PYTHON SPECIFICS
        ["Decorator"] = " ", -- Магія/Декоратор (nf-fa-magic)
        ["Module"] = " ", -- Модуль/Пакет (nf-mdi-package-variant)
        ["Namespace"] = " ", -- Директорія/Пакет (nf-oct-file-directory)
        ["Package"] = "󰏖 ", -- Імпорт/Пакет (nf-mdi-package)
        ["TypeParameter"] = "󰛫 ", -- TypeVar / Generic (nf-mdi-alpha-t-circle)
        ["TypeAlias"] = " ", -- Typing Alias (nf-fa-font)
        ["File"] = " ", -- Python файл (nf-dev-python)

        -- КЛАСИ ТА СТРУКТУРИ
        ["Class"] = "󰠱 ", -- Клас (nf-mdi-language-python) - лого Python!
        ["Interface"] = " ", -- Інтерфейс (Protocol)
        ["Struct"] = "󰌗 ", -- Dataclass / Pydantic Model
        ["Enum"] = " ", -- Enum
        ["EnumMember"] = " ",

        -- ФУНКЦІЇ ТА МЕТОДИ
        ["Function"] = "󰊕 ", -- Звичайна функція (def)
        ["Method"] = " ", -- Метод класу
        ["Constructor"] = " ", -- __init__

        -- ЗМІННІ ТА АТРИБУТИ
        ["Field"] = " ", -- Атрибут класу (self.x)
        ["Property"] = "󰜢 ", -- @property
        ["Variable"] = " ", -- Глобальна/локальна змінна
        ["Constant"] = "󰏿 ", -- КОНСТАНТА (UPPER_CASE)

        --  ІНШЕ
        ["Event"] = " ",
        ["Operator"] = "󰆕 ",
        ["Key"] = " ",
        ["Null"] = " ",
        ["Boolean"] = " ",
        ["Array"] = " ",
        ["Number"] = "󰎠 ",
        ["Object"] = "󰅩 ",
        ["String"] = " ",
      },
      -- 🔹 4. ПІДСВІЧУВАННЯ ТА ПОВЕДІНКА
      highlight_mode = "split_width",
      highlight_closest = true,
      highlight_on_hover = true,
      highlight_on_jump = 300,
      autojump = false,
      show_guides = true,
      guides = {
        mid_item = "├─",
        last_item = "└─",
        nested_top = "│ ",
        whitespace = "  ",
      },
      get_highlight = function(symbol, is_icon, is_collapsed)
        local kind = symbol.kind
        local name = symbol.name or ""
        if name:match("^🔒 ") then
          return is_icon and "AerialPrivateIcon" or "AerialPrivateText"
        end
        if is_icon then
          if kind == "Function" or kind == "Method" then
            return "AerialFunctionIcon"
          elseif kind == "Class" or kind == "Struct" or kind == "Interface" then
            return "AerialClassIcon"
          elseif kind == "Variable" or kind == "Field" then
            return "AerialVariableIcon"
          elseif kind == "Constant" then
            return "AerialConstantIcon"
          elseif kind == "Package" or kind == "Module" then
            return "AerialPackageIcon"
          elseif kind == "Enum" or kind == "Type" then
            return "AerialTypeIcon"
          end
        else
          return "Aerial" .. kind
        end
      end,

      -- 🔹 5. KEYMAPS У ВІКНІ AERIAL
      keymaps = {
        ["?"] = "actions.show_help",
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.jump",
        ["<2-LeftMouse>"] = "actions.jump",
        ["<C-v>"] = "actions.jump_vsplit",
        ["<C-s>"] = "actions.jump_split",
        ["<C-t>"] = "actions.jump_tab",
        ["p"] = "actions.scroll",
        ["<C-j>"] = "actions.down_and_scroll",
        ["<C-k>"] = "actions.up_and_scroll",
        ["<C-d>"] = "actions.scroll_down",
        ["<C-u>"] = "actions.scroll_up",
        ["{"] = "actions.prev",
        ["}"] = "actions.next",
        ["[["] = "actions.prev_up",
        ["]]"] = "actions.next_up",
        ["o"] = "actions.tree_toggle",
        ["za"] = "actions.tree_toggle",
        ["O"] = "actions.tree_toggle_recursive",
        ["zA"] = "actions.tree_toggle_recursive",
        ["l"] = "actions.tree_open",
        ["zo"] = "actions.tree_open",
        ["L"] = "actions.tree_open_recursive",
        ["zO"] = "actions.tree_open_recursive",
        ["h"] = "actions.tree_close",
        ["zc"] = "actions.tree_close",
        ["H"] = "actions.tree_close_recursive",
        ["zC"] = "actions.tree_close_recursive",
        ["zr"] = "actions.tree_increase_fold_level",
        ["zm"] = "actions.tree_decrease_fold_level",
        ["zR"] = "actions.tree_open_all",
        ["zM"] = "actions.tree_close_all",
        ["zx"] = "actions.tree_sync_folds",
        ["zX"] = "actions.tree_sync_folds",
        ["<C-f>"] = "actions.focus",
        ["<C-r>"] = "actions.refresh",
        ["<C-w>"] = "actions.widen",
        ["<C-n>"] = "actions.narrow",
        ["<C-a>"] = "actions.toggle_ignore",
        ["<C-g>"] = "actions.goto_file",
        ["q"] = "actions.close",
        ["<Esc>"] = "actions.close",
        ["<C-c>"] = "actions.close",
      },

      -- 🔹 6. ON_ATTACH: МАППІНГИ ДЛЯ БУФЕРА З КОДОМ
      on_attach = function(bufnr)
        vim.keymap.set(
          "n",
          "{",
          "<cmd>AerialPrev<CR>",
          { buffer = bufnr, desc = "🔼 Aerial: попередній символ" }
        )
        vim.keymap.set(
          "n",
          "}",
          "<cmd>AerialNext<CR>",
          { buffer = bufnr, desc = "🔽 Aerial: наступний символ" }
        )

        for i = 1, 9 do
          vim.keymap.set("n", "<leader>" .. i, function()
            vim.cmd("AerialGo " .. i)
          end, { buffer = bufnr, desc = "🔢 Aerial: стрибок до символу #" .. i })
        end

        vim.keymap.set("n", "<leader>af", function()
          require("aerial").toggle_filter()
        end, { buffer = bufnr, desc = "🔀 Aerial: toggle filter" })

        vim.keymap.set("n", "<leader>ar", "<cmd>AerialRefresh<CR>", { buffer = bufnr, desc = "🔄 Aerial: refresh" })
      end,

      -- 🔹 7. ПОВЕДІНКА ТА ПРОДУКТИВНІСТЬ
      close_on_select = false,
      post_jump_cmd = "normal! zz",
      disable_max_lines = 15000,
      disable_max_size = 3000000,
      update_events = { "TextChanged", "InsertLeave", "BufWritePost" },
      update_delay = 200,

      -- 🔹 8. FLOATING ВІКНО
      float = {
        border = "rounded",
        relative = "cursor",
        min_height = { 8, 0.1 },
        height = nil,
        max_height = 0.9,
        min_width = { 30, 0.2 },
        width = nil,
        max_width = { 60, 0.4 },
        win_opts = { winblend = 10, cursorline = true },
        override = function(conf, source_winid)
          local ft = vim.bo.filetype
          if ft == "go" or ft == "rust" or ft == "python" then
            conf.width = math.min(70, vim.o.columns * 0.3)
          end
          return conf
        end,
      },

      -- 🔹 9. NAV-ВІКНО (ПОПЕРЕДНІЙ ПЕРЕГЛЯД)
      nav = {
        border = "rounded",
        max_height = 0.9,
        min_height = { 10, 0.1 },
        max_width = 0.5,
        min_width = { 0.2, 25 },
        win_opts = { cursorline = true, winblend = 10, signcolumn = "no" },
        preview = { enabled = true, layout = "right", width = 0.4 },
        autojump = false,
        keymaps = {
          ["<CR>"] = "actions.jump",
          ["<2-LeftMouse>"] = "actions.jump",
          ["<C-v>"] = "actions.jump_vsplit",
          ["<C-s>"] = "actions.jump_split",
          ["<C-t>"] = "actions.jump_tab",
          ["h"] = "actions.left",
          ["l"] = "actions.right",
          ["<C-c>"] = "actions.close",
          ["q"] = "actions.close",
        },
      },

      -- 🔹 10. LSP ТА TREESITTER (🔥 БЕЗ ПРИОРІТЕТІВ МОВ, ВСІ РІВНІ)
      lsp = {
        diagnostics_trigger_update = false,
        update_when_errors = true,
        update_delay = 300,
      },
      treesitter = {
        update_delay = 150,
      },

      -- 🔹 11. POST-ОБРОБКА СИМВОЛІВ (РОЗУМНА ЛОГІКА ДЛЯ PYTHON)
      post_parse_symbol = function(bufnr, item, ctx)
        local lang = ctx.lang or ""
        local name = item.name or ""
        local kind = item.kind or ""

        --  ЛОГІКА ДЛЯ PYTHON
        if lang == "python" or lang == "py" then
          -- 1. Магічні методи (Dunder methods): __init__, __str__, __call__
          if name:match("^__.*__$") then
            item.name = "  " .. name -- Гайковий ключ для магії
            return true
          end

          -- 2. Приватні методи/змінні: _internal, __hidden
          if name:match("^_+") then
            item.name = "󰌗  " .. name -- Замок для приватного
            return true
          end

          -- 3. Декоратори (якщо LSP віддав їх як Property або Function з @)
          -- Aerial іноді парсить декоратори, якщо вони є в treesitter
          if name:match("^@") or kind == "Decorator" then
            item.name = "󰆧 " .. name:gsub("^@", "")
            return true
          end

          -- 4. Константи (UPPER_CASE_WITH_UNDERSCORES)
          if name:match("^[A-Z][A-Z0-9_]+$") then
            item.name = " " .. name -- Шпилька для констант
            return true
          end
        end

        --  ЛОГІКА ДЛЯ GO (залишаємо вашу стару)
        if lang == "go" and name:match("^%l") then
          item.name = "🔒 " .. name
        end

        -- 🧪 ТЕСТИ (Універсально)
        if name:match("^Test") or name:match("^Benchmark") or name:match("^test_") then
          item.name = "🧪 " .. name:gsub("^🔒 ", "")
        end

        return true
      end,

      -- 🔹 12. ІГНОРУВАННЯ ВІКОН/БУФЕРІВ
      ignore = {
        unlisted_buffers = true,
        diff_windows = true,
        filetypes = {
          "help",
          "man",
          "dashboard",
          "startify",
          "qf",
          "loclist",
          "NvimTree",
          "neo-tree",
          "aerial",
          "TelescopePrompt",
          "oil",
          "dropbar_menu",
          "noice",
          "fzf",
          "snacks_picker",
        },
        buftypes = "special",
        wintypes = "special",
      },

      -- 🔹 13. УПРАВЛІННЯ FOLDS
      manage_folds = false,
      link_folds_to_tree = false,
      link_tree_to_folds = true,
    } -- 🔹 ЦЯ ДУЖКА ЗАКРИВАЄ ТАБЛИЦЮ opts ПОВНІСТЮ!
  end,

  -- ========================================================================
  -- 🔹 14. ДОДАТКОВІ КОМАНДИ ТА АВТОЗАПУСК (CONFIG)
  -- ========================================================================
  config = function(_, opts)
    require("aerial").setup(opts)

    -- Користувацькі команди для фільтрації
    vim.api.nvim_create_user_command("AerialGoStructs", function()
      require("aerial").open({ filter_kind = { "Struct", "Interface", "Class" } })
    end, { desc = "Aerial: показати тільки Struct/Interface/Class" })

    vim.api.nvim_create_user_command("AerialGoFuncs", function()
      require("aerial").open({ filter_kind = { "Function", "Method" } })
    end, { desc = "Aerial: показати тільки функції/методи" })

    -- Автоматичне відкриття при вході в підтримувані файли (опціонально)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {
        "go",
        "python",
        "lua",
        "rust",
        "typescript",
        "javascript",
        "yaml",
        "terraform",
        "php",
        "bash",
        "sh",
        "zsh",
        "json",
        "markdown",
      },
      callback = function()
        vim.defer_fn(function()
          if vim.bo.buftype == "" and not require("aerial").is_open() then
            -- require("aerial").open() -- Розкоментуйте, якщо хочете, щоб він відкривався САМ при старті
          end
        end, 150)
      end,
    })
  end,
}
