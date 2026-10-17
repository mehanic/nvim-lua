return {
  "shellRaining/hlchunk.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = function()
    return {
      -- 🔹 ТІЛЬКИ ЧАНК (рамки навколо блоку)
      chunk = {
        enable = true,
        chars = {
          horizontal_line = "━",
          vertical_line = "┃",
          left_top = "┏",
          left_bottom = "┗",
          right_arrow = "─",
        },
        style = {
          { fg = "#FAB387" },
        },
        -- 🔹 Глобальні налаштування перенесені ВНУТРІ модуля
        notify = false,
        exclude_filetypes = {
          aerial = true,
          dashboard = true,
          NvimTree = true,
          ["neo-tree"] = true,
          TelescopePrompt = true,
          oil = true,
          dropbar_menu = true,
          terminal = true,
          snacks_picker = true,
          help = true,
          man = true,
        },
      },

      -- 🔹 Явно вимикаємо інші модулі, щоб плагін не намагався їх ініціалізувати
      indent = { enable = false },
      line_num = { enable = false },
      blank = { enable = false },
    }
  end,
}
