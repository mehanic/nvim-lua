return {
  "kawre/leetcode.nvim",
  build = ":TSUpdate html", -- Оновлює парсер HTML для коректного відображення умов задач
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    -- 🔹 Мова за замовчуванням
    lang = "golang",
    -- lang = "python3", -- Розкоментуйте, якщо потрібно змінити

    -- 🔹 Гарячі клавіші (вбудовані в сам плагін)
    keymaps = {
      list = "<leader>ll",
      solve = "<leader>ls",
      test = "<leader>lt",
      submit = "<leader>lsb",
    },

    -- 🔹 Важливо для роботи разом з іншими плагінами
    plugins = {
      non_standalone = true,
    },

    -- 🔹 Додаткові покращення UI (рекомендовано)
    injector = {},
    storage = {
      home = vim.fn.stdpath("data") .. "/leetcode",
    },
  },

  -- 🔹 Налаштування та кастомні команди
  config = function(_, opts)
    local leetcode = require("leetcode")
    leetcode.setup(opts)

    -- 🔹 Словник кастомних команд для чистоти коду
    local custom_commands = {
      LeetcodeLL = "Leet list",
      LeetcodeLS = "Leet solve",
      LeetcodeLT = "Leet test",
      LeetcodeLSB = "Leet submit",
      LeetcodeEasy = "Leet list tags=easy",
      LeetcodeMedium = "Leet list tags=medium",
      LeetcodeHard = "Leet list tags=hard",
      LeetcodeTop = "Leet list tags=top-interview-questions",
    }

    -- 🔹 Реєстрація команд циклом (замість 8 окремих блоків)
    for cmd_name, leet_action in pairs(custom_commands) do
      vim.api.nvim_create_user_command(cmd_name, function()
        vim.cmd(leet_action)
      end, { desc = "Leetcode: " .. leet_action })
    end
  end,

  -- 🔹 Ліниве завантаження: завантажується тільки при виклику команд
  cmd = {
    "Leet",
    "LeetcodeLL",
    "LeetcodeLS",
    "LeetcodeLT",
    "LeetcodeLSB",
    "LeetcodeEasy",
    "LeetcodeMedium",
    "LeetcodeHard",
    "LeetcodeTop",
  },
}
