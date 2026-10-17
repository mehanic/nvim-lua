return {
  "chrisgrieser/nvim-rip-substitute",
  cmd = "RipSubstitute", -- Ліниве завантаження за командою
  dependencies = {
    -- Рекомендується встановити парсер regex для підсвітки синтаксису в popup-вікні
    {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        table.insert(opts.ensure_installed, "regex")
      end,
    },
  },
  opts = {
    popupWin = {
      title = " rip-substitute",
      border = "rounded",
      position = "bottom",
    },
    prefill = {
      normal = "cursorWord", -- Автоматично підставляє слово під курсором у звичайному режимі
      visual = "selection", -- Автоматично підставляє виділений текст у візуальному режимі
    },
    keymaps = {
      abort = "q",
      confirmAndSubstituteInBuffer = "<CR>", -- Замінити в поточному буфері
      confirmAndSubstituteInCwd = "<S-CR>", -- Замінити у всьому проєкті (Shift+Enter)
      openAtRegex101 = "R", -- Відкрити в Regex101
      showHelp = "?",
    },
    regexOptions = {
      pcre2 = true, -- Увімкнути сучасні регулярки (lookarounds тощо)
    },
  },
  keys = {
    {
      "<leader>rs",
      function()
        require("rip-substitute").sub()
      end,
      mode = { "n", "x" }, -- Працює в звичайному та візуальному режимах
      desc = " Rip Substitute (Search & Replace)",
    },
  },
}
