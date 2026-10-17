return {
  -- ========================================================================
  -- 🔹 1. GITSIGNS.NVIM (Повсякденний візуалізатор змін)
  -- ========================================================================
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "" },
        change = { text = "" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      -- Показувати Git blame поточного рядка праворуч
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 500,
        ignore_whitespace = false,
      },
      -- Не показувати знаки в порожніх буферах
      attach_to_untracked = true,
    },
    -- Явні клавіші для швидкої роботи з хунками (шматками коду)
    keys = {
      -- ✅ ВИПРАВЛЕНО: використовуємо новий API nav_hunk()
      {
        "]c",
        function()
          require("gitsigns").nav_hunk("next")
        end,
        desc = "🔹 Next Git Hunk",
      },
      {
        "[c",
        function()
          require("gitsigns").nav_hunk("prev")
        end,
        desc = "🔹 Prev Git Hunk",
      },
      {
        "<leader>hs",
        function()
          require("gitsigns").stage_hunk()
        end,
        desc = "🔹 Stage Hunk",
      },
      {
        "<leader>hr",
        function()
          require("gitsigns").reset_hunk()
        end,
        desc = "🔹 Reset Hunk",
      },
      {
        "<leader>hp",
        function()
          require("gitsigns").preview_hunk()
        end,
        desc = "🔹 Preview Hunk",
      },
      {
        "<leader>hb",
        function()
          require("gitsigns").blame_line({ full = true })
        end,
        desc = "🔹 Blame Line",
      },
    },
  },

  -- ========================================================================
  -- 🔹 2. LAZYGIT.NVIM (Повноцінний TUI для складних операцій)
  -- ========================================================================
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "🔹 Open LazyGit (Root)" },
      { "<leader>g.", "<cmd>LazyGitCurrentFile<cr>", desc = "🔹 Open LazyGit (Current File)" },
      { "<leader>gf", "<cmd>LazyGitFilter<cr>", desc = " LazyGit Filter" },
    },
  },

  -- ========================================================================
  -- 🔹 3. GIT-CONFLICT.NVIM (Миттєве вирішення конфліктів)
  -- ========================================================================
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    config = true, -- Автоматично застосовує дефолтні налаштування (підсвітка, маркери)
    keys = {
      -- Навігація між конфліктами у файлі
      { "]x", "<cmd>GitConflictNextConflict<cr>", desc = "🔹 Next Conflict" },
      { "[x", "<cmd>GitConflictPrevConflict<cr>", desc = "🔹 Prev Conflict" },
      -- Вибір рішення для поточного конфлікту
      { "<leader>gc", "<cmd>GitConflictChooseOurs<cr>", desc = " Choose OURS (Current)" },
      { "<leader>gt", "<cmd>GitConflictChooseTheirs<cr>", desc = "🔹 Choose THEIRS (Incoming)" },
      { "<leader>gb", "<cmd>GitConflictChooseBoth<cr>", desc = " Choose BOTH" },
      { "<leader>gn", "<cmd>GitConflictChooseNone<cr>", desc = "🔹 Choose NONE (Delete block)" },
    },
  },
}
