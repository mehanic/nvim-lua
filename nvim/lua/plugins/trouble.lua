return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    -- 🔹 Позиція та розмір
    position = "bottom",
    height = 15,
    width = 40,

    -- 🔹 Іконки (тепер таблиця, а не boolean!)
    icons = {
      enabled = true,
      folder_closed = "",
      folder_open = "",
      kinds = require("mini.icons").get, -- або nil якщо немає mini.icons
    },

    -- 🔹 Вигляд
    indent_lines = true,
    multiline = true,
    padding = true,
    cycle_results = true,

    -- 🔹 Групування
    group = true,

    -- 🔹 Серйозність (nil = всі)
    severity = nil,

    -- 🔹 Автоповедінка
    auto_open = false,
    auto_close = false,
    auto_preview = true,
    auto_fold = false,
    auto_jump = { "lsp_definitions" },

    -- 🔹 Вікно
    win = {
      type = "split",
      position = "bottom",
      size = 15,
      border = "rounded",
    },

    -- 🔹 Іконки для рівнів серйозності
    signs = {
      error = "",
      warning = "",
      hint = "",
      information = "",
      other = "",
    },
    use_diagnostic_signs = false,

    -- 🔹 Клавіші
    keys = {
      ["<esc>"] = "close",
      ["q"] = "close",
      ["r"] = "refresh",
      ["<cr>"] = "jump",
      ["<tab>"] = "jump",
      ["o"] = "jump_close",
      ["<c-x>"] = "open_split",
      ["<c-v>"] = "open_vsplit",
      ["<c-t>"] = "open_tab",
      ["m"] = "toggle_mode",
      ["s"] = "switch_severity",
      ["P"] = "toggle_preview",
      ["K"] = "hover",
      ["p"] = "preview",
      ["zM"] = "close_folds",
      ["zR"] = "open_folds",
      ["zA"] = "toggle_fold",
      ["k"] = "previous",
      ["j"] = "next",
      ["?"] = "help",
    },
  },

  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = " Diagnostics (Workspace)" },
    { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "🟡 Diagnostics (Current Buffer)" },
    { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "📑 Document Symbols" },
    { "<leader>cS", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "🔗 LSP" },
    { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "📍 Location List" },
    { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "📋 Quickfix List" },
  },
}
