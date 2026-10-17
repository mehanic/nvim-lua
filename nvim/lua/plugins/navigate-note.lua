return {
  "you-n-g/navigate-note.nvim",
  opts = {
    filename = "nav.md", -- Назва файлу нотаток
    width = 0.6, -- Ширина вікна попереднього перегляду
    keymaps = {
      nav_mode = {
        open = "<m-cr>", -- Відкрити файл/рядок під курсором
        switch_back = "<m-h>", -- Повернутися назад з nav.md
        append_link = "<m-p>", -- Додати поточний файл/рядок у nav.md
      },
      open_nav = "<m-h>", -- Відкрити сам файл nav.md
    },
    -- Приклад Tmux інтеграції: за замовчуванням відправляти в певне вікно
    default_tmux_target = "tmux://{current}:dev_window",
  },
}
