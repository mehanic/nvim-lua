return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>lf",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      desc = "🎨 Format buffer",
    },
  },
  opts = {
    format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
    default_format_opts = { lsp_format = "fallback" },
    log_level = vim.log.levels.ERROR,
    notify_on_error = true,
    notify_no_formatters = false,

    -- 🔹 1. КАСТОМНІ ФОРМАТТЕРИ (З вашого першого скрипта)
    formatters = {
      -- Ruff замість Black/Isort (набагато швидше)
      ruff_fix = { command = "ruff", args = { "check", "--fix", "--stdin-filename", "$FILENAME" } },
      ruff_format = { command = "ruff", args = { "format", "--stdin-filename", "$FILENAME" } },

      -- Deno замість Prettier для веб-технологій
      deno_fmt = { command = "deno", args = { "fmt", "-", "--ext", "$FILEEXT" } },

      -- Sqruff для SQL
      sqruff = { command = "sqruff", args = { "fix", "-" } },

      -- Налаштування shfmt (відступи 2 пробіли)
      shfmt = { prepend_args = { "-i", "2" } },
    },

    -- 🔹 2. МАППІНГ МОВ НА ФОРМАТТЕРИ
    formatters_by_ft = {
      lua = { "stylua" },

      -- Python: спочатку Ruff, потім LSP
      python = { "ruff_fix", "ruff_format", "isort", lsp_format = "fallback" },

      -- Web/Config: Deno (швидко), потім Prettierd/Prettier (фолбек)
      javascript = { "deno_fmt", "prettierd", "prettier", stop_after_first = true },
      typescript = { "deno_fmt", "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "deno_fmt", "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "deno_fmt", "prettierd", "prettier", stop_after_first = true },
      json = { "deno_fmt", "prettierd", "prettier", stop_after_first = true },
      jsonc = { "deno_fmt", "prettierd", "prettier", stop_after_first = true },
      yaml = { "deno_fmt", "prettierd", "prettier", stop_after_first = true },
      markdown = { "deno_fmt", "prettierd", "prettier", stop_after_first = true },
      html = { "deno_fmt", "prettierd", "prettier", stop_after_first = true },
      css = { "deno_fmt", "prettierd", "prettier", stop_after_first = true },

      -- SQL
      sql = { "sqruff" },

      -- Go, Rust, Bash
      go = { "gofmt", "goimports" },
      rust = { "rustfmt" },
      bash = { "shfmt" },
      sh = { "shfmt" },

      -- Видаляти зайві пробіли у ВСІХ файлах
      ["*"] = { "trim_whitespace" },
    },
  },
}
