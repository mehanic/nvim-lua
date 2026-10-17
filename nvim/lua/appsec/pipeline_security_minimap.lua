-- ========================================================================
-- 🗺️ NEOMINIMAP + PIPELINE: візуалізація проблем на мінімапі
-- ========================================================================

return {
  -- Залежність від neominimap
  {
    "helino/neominimap.nvim",
    lazy = false,
    opts = {},
  },

  -- Основний модуль для інтеграції
  {
    "your-username/appsec-pipeline", -- або інший плагін з пайплайном
    dependencies = { "helino/neominimap.nvim" },
    config = function()
      -- ========================================================================
      -- 🔹 Highlight групи для маркерів (Nord палітра)
      -- ========================================================================
      local highlights = {
        NeominimapSecSecret = { fg = "#bf616a", bg = "#3b4252", bold = true }, -- червоний для секретів
        NeominimapSecScan = { fg = "#d08770", bg = "#3b4252", bold = true }, -- помаранчевий для SAST
        NeominimapSecInfra = { fg = "#88c0d0", bg = "#3b4252", bold = true }, -- синій для IaC
        NeominimapSecInfo = { fg = "#a3be8c", bg = "#3b4252", bold = true }, -- зелений для інфо
      }

      for group, opts in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, opts)
      end

      -- ========================================================================
      -- 🔹 Функції для роботи з маркерами
      -- ========================================================================

      --- Додати тимчасовий маркер на мінімапі під час виконання пайплайну
      ---@param bufnr number
      ---@param lnum number
      ---@param icon string
      ---@param hl_group string
      local function add_minimap_marker(bufnr, lnum, icon, hl_group)
        if not vim.g.neominimap then
          return
        end

        local ns = vim.api.nvim_create_namespace("pipeline_minimap")
        vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, 0, {
          virt_text = { { icon .. " ", hl_group } },
          virt_text_pos = "right_align",
          priority = 2000, -- вище за звичайні маркери
        })

        -- Оновити мінімапу
        pcall(function()
          require("neominimap").refresh()
        end)
      end

      --- Очистити тимчасові маркери пайплайну
      ---@param bufnr number
      local function clear_pipeline_markers(bufnr)
        local ns = vim.api.nvim_create_namespace("pipeline_minimap")
        vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
        pcall(function()
          require("neominimap").refresh()
        end)
      end

      --- Хелпер: загорнути крок пайплайну для візуалізації на мінімапі
      ---@param step_fn fun() Оригінальна функція кроку
      ---@param icon string Іконка для мінімапи (наприклад "🔍")
      ---@param hl_group string Highlight-група (наприклад "NeominimapSecHigh")
      ---@return fun()
      local function with_minimap_feedback(step_fn, icon, hl_group)
        return function()
          local bufnr = vim.api.nvim_get_current_buf()
          local lnum = vim.api.nvim_win_get_cursor(0)[1]

          -- Додати маркер перед виконанням
          add_minimap_marker(bufnr, lnum, icon, hl_group)

          -- Виконати оригінальний крок
          local result = step_fn()

          -- Очистити маркер після завершення (з невеликою затримкою для візуального ефекту)
          vim.defer_fn(function()
            clear_pipeline_markers(bufnr)
          end, 500)

          return result
        end
      end

      -- ========================================================================
      -- 🔹 Експорт функцій для використання в інших модулях
      -- ========================================================================
      _G.add_minimap_marker = add_minimap_marker
      _G.clear_pipeline_markers = clear_pipeline_markers
      _G.with_minimap_feedback = with_minimap_feedback

      -- ========================================================================
      -- 🔹 Приклад використання (закоментовано)
      -- ========================================================================
      -- У вашому appsec_pipeline.lua:
      -- {
      --   name = "🔐 TruffleHog",
      --   fn = with_minimap_feedback(
      --     require("pipeline").trufflehog_step("filesystem", ".", {fail_on_find=false}),
      --     "🔐",  -- іконка на мінімапі
      --     "NeominimapSecSecret"  -- колір
      --   ),
      --   ignore_errors = true,
      -- }
    end,
  },
}
