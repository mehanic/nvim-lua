return {
  "maxandron/goplements.nvim",
  ft = "go",
  opts = {
    -- 🔹 Префікси для відображення
    prefix = {
      interface = "implemented by: ", -- Показує хто реалізує інтерфейс
      struct = "implements: ", -- Показує які інтерфейси реалізує структура
    },

    -- 🔹 Показувати назву пакету (наприклад, "builtins.error" замість "error")
    display_package = false,

    -- 🔹 Namespace для extmarks (не змінювати без потреби)
    namespace_name = "goplements",

    -- 🔹 Highlight група (використовує DiagnosticHint за замовчуванням)
    highlight = "Goplements",
  },
}
