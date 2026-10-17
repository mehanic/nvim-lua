return {
  -- ========================================================================
  -- 🔹 BASH/SHELL: Кастомна підсвітка синтаксису + Security
  -- ========================================================================

  -- 1️ Примусово використовуємо bash-парсер для .sh файлів
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, "bash")
    end,
  },

  -- 2️ Основна конфігурація
  config = function()
    -- ========================================================================
    -- 🔹 ПРИМУСОВИЙ FILETYPE
    -- ========================================================================
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
      pattern = "*.sh",
      callback = function()
        vim.bo.filetype = "bash"
      end,
    })

    -- ========================================================================
    -- 🔹 БАЗОВА ПІДСВІТКА СИНТАКСИСУ (ваша існуюча палітра)
    -- ========================================================================
    local function apply_bash_syntax_colors()
      local yellow, cyan, peach, green, text, gray = "#ebcb8b", "#88c0d0", "#FFB347", "#c3e88d", "#eeffff", "#4c566a"

      -- Treesitter
      vim.api.nvim_set_hl(0, "@keyword", { fg = yellow, bold = true, link = nil })
      vim.api.nvim_set_hl(0, "@keyword.conditional", { fg = yellow, link = nil })
      vim.api.nvim_set_hl(0, "@keyword.repeat", { fg = yellow, link = nil })
      vim.api.nvim_set_hl(0, "@keyword.function", { fg = peach, bold = true, link = nil })
      vim.api.nvim_set_hl(0, "@function", { fg = cyan, bold = true, link = nil })
      vim.api.nvim_set_hl(0, "@function.call", { fg = cyan, link = nil })
      vim.api.nvim_set_hl(0, "@function.builtin", { fg = yellow, bold = true, link = nil })
      vim.api.nvim_set_hl(0, "@variable", { fg = text, link = nil })
      vim.api.nvim_set_hl(0, "@variable.builtin", { fg = "#f07178", bold = true, link = nil })
      vim.api.nvim_set_hl(0, "@variable.parameter", { fg = "#7dcfff", italic = true, link = nil })
      vim.api.nvim_set_hl(0, "@string", { fg = green, link = nil })
      vim.api.nvim_set_hl(0, "@string.special", { fg = "#a3be8c", bold = true, link = nil })
      vim.api.nvim_set_hl(0, "@number", { fg = "#f78c6c", link = nil })
      vim.api.nvim_set_hl(0, "@constant", { fg = "#d08770", bold = true, link = nil })
      vim.api.nvim_set_hl(0, "@comment", { fg = gray, italic = true, link = nil })

      -- Legacy Vim Syntax
      vim.api.nvim_set_hl(0, "shStatement", { fg = yellow, bold = true, link = nil })
      vim.api.nvim_set_hl(0, "shConditional", { fg = yellow, link = nil })
      vim.api.nvim_set_hl(0, "shFunctionKey", { fg = peach, bold = true, link = nil })
      vim.api.nvim_set_hl(0, "shFunctionName", { fg = cyan, link = nil })
      vim.api.nvim_set_hl(0, "bashFunction", { fg = cyan, link = nil })
      vim.api.nvim_set_hl(0, "shCase", { fg = yellow, bold = true, link = nil })
      vim.api.nvim_set_hl(0, "shCaseEsac", { fg = yellow, bold = true, link = nil })
      vim.api.nvim_set_hl(0, "shCommand", { fg = yellow, link = nil })
      vim.api.nvim_set_hl(0, "shEcho", { fg = yellow, link = nil })
      vim.api.nvim_set_hl(0, "bashBuiltin", { fg = yellow, link = nil })
      vim.api.nvim_set_hl(0, "shVariable", { fg = text, link = nil })
      vim.api.nvim_set_hl(0, "bashSpecialVariables", { fg = "#f07178", bold = true, link = nil })
      vim.api.nvim_set_hl(0, "shString", { fg = green, link = nil })
      vim.api.nvim_set_hl(0, "bashSubstitution", { fg = "#a3be8c", bold = true, link = nil })
      vim.api.nvim_set_hl(0, "bashRedir", { fg = "#ff9e64", link = nil })

      -- LSP Semantic Tokens
      vim.api.nvim_set_hl(0, "@lsp.type.keyword", { fg = yellow, bold = true, link = nil })
      vim.api.nvim_set_hl(0, "@lsp.type.function", { fg = cyan, bold = true, link = nil })
      vim.api.nvim_set_hl(0, "@lsp.type.builtin", { fg = yellow, bold = true, link = nil })
      vim.api.nvim_set_hl(0, "@lsp.type.variable", { fg = text, link = nil })
      vim.api.nvim_set_hl(0, "@lsp.type.string", { fg = green, link = nil })
      vim.api.nvim_set_hl(0, "@lsp.type.comment", { fg = gray, italic = true, link = nil })
    end

    -- ========================================================================
    -- 🔹 SECURITY-FOCUSED ПІДСВІТКА (НОВЕ!)
    -- ========================================================================

    -- 1. Визначаємо highlight групи для security
    local function apply_security_highlights()
      --  Небезпечні команди (eval, exec, source)
      vim.api.nvim_set_hl(0, "BashSecDangerous", { fg = "#bf616a", bg = "#3b4252", bold = true, link = nil })

      --  Критичні патерни (curl|sh, wget|bash)
      vim.api.nvim_set_hl(
        0,
        "BashSecCritical",
        { fg = "#bf616a", bg = "#4c0a0a", bold = true, underline = true, link = nil }
      )

      -- 🟢 Безпечні прапори (set -e, trap)
      vim.api.nvim_set_hl(0, "BashSecSafe", { fg = "#a3be8c", bg = "#2e3440", bold = true, link = nil })

      -- 🟠 Чутливі команди (chmod, chown, sudo)
      vim.api.nvim_set_hl(0, "BashSecSensitive", { fg = "#d08770", bold = true, link = nil })

      -- 🔑 Змінні з секретами (PASSWORD, TOKEN, SECRET)
      vim.api.nvim_set_hl(0, "BashSecSecret", { fg = "#b48ead", bg = "#3b4252", bold = true, link = nil })
    end

    -- 2. Namespace для extmarks
    local sec_ns = vim.api.nvim_create_namespace("bash_security")

    -- 3. Функція застосування security-підсвітки через extmarks
    local function apply_security_markers(bufnr)
      bufnr = bufnr or vim.api.nvim_get_current_buf()
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      if vim.bo[bufnr].filetype ~= "bash" then
        return
      end

      -- Очищаємо старі маркери
      vim.api.nvim_buf_clear_namespace(bufnr, sec_ns, 0, -1)

      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

      for lnum, line in ipairs(lines) do
        local clean_line = line:gsub("#.*$", "") -- Ігноруємо коментарі

        -- 🔴 Небезпечні команди
        if
          clean_line:match("%beval%s")
          or clean_line:match("%bexec%s")
          or clean_line:match("%bsource%s")
          or clean_line:match("%.%s")
        then
          vim.api.nvim_buf_add_highlight(bufnr, sec_ns, "BashSecDangerous", lnum - 1, 0, -1)
        end

        -- 🚨 Критичні патерни: curl|sh, wget|bash
        if
          clean_line:match("curl%s.*|%s*sh")
          or clean_line:match("curl%s.*|%s*bash")
          or clean_line:match("wget%s.*|%s*sh")
          or clean_line:match("wget%s.*|%s*bash")
        then
          vim.api.nvim_buf_add_highlight(bufnr, sec_ns, "BashSecCritical", lnum - 1, 0, -1)
        end

        -- 🟢 Безпечні прапори
        if
          clean_line:match("set%s+%-e")
          or clean_line:match("set%s+%-u")
          or clean_line:match("set%s+%-o%s+pipefail")
          or clean_line:match("trap%s+")
        then
          vim.api.nvim_buf_add_highlight(bufnr, sec_ns, "BashSecSafe", lnum - 1, 0, -1)
        end

        -- 🟠 Чутливі команди
        if
          clean_line:match("%bchmod%s")
          or clean_line:match("%bchown%s")
          or clean_line:match("%bsudo%s")
          or clean_line:match("%bpasswd%s")
          or clean_line:match("%buseradd%s")
          or clean_line:match("%busermod%s")
        then
          vim.api.nvim_buf_add_highlight(bufnr, sec_ns, "BashSecSensitive", lnum - 1, 0, -1)
        end

        -- 🔑 Змінні з секретами
        if
          clean_line:match("[A-Z_]*PASSWORD[A-Z_]*%s*=")
          or clean_line:match("[A-Z_]*SECRET[A-Z_]*%s*=")
          or clean_line:match("[A-Z_]*TOKEN[A-Z_]*%s*=")
          or clean_line:match("[A-Z_]*KEY[A-Z_]*%s*=")
          or clean_line:match("[A-Z_]*API_KEY[A-Z_]*%s*=")
        then
          vim.api.nvim_buf_add_highlight(bufnr, sec_ns, "BashSecSecret", lnum - 1, 0, -1)
        end
      end
    end

    -- ========================================================================
    -- 🔹 ЗАСТОСУВАННЯ ПІДСВІТКИ
    -- ========================================================================
    local bash_group = vim.api.nvim_create_augroup("BashSyntaxColors", { clear = true })

    -- При відкритті bash-файлу
    vim.api.nvim_create_autocmd("FileType", {
      group = bash_group,
      pattern = "bash",
      callback = function()
        apply_bash_syntax_colors()
        apply_security_highlights()
        vim.defer_fn(function()
          apply_security_markers()
        end, 100)
      end,
    })

    -- При зміні тексту (для оновлення security-маркерів)
    vim.api.nvim_create_autocmd("TextChanged", {
      group = bash_group,
      pattern = "*.sh",
      callback = function(args)
        if vim.bo[args.buf].filetype == "bash" then
          vim.defer_fn(function()
            apply_security_markers(args.buf)
          end, 500) -- Затримка для уникнення лагів
        end
      end,
    })

    -- При зміні теми
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = bash_group,
      callback = function()
        if vim.bo.filetype == "bash" then
          apply_bash_syntax_colors()
          apply_security_highlights()
          apply_security_markers()
        end
      end,
    })

    -- При підключенні LSP
    vim.api.nvim_create_autocmd("LspAttach", {
      group = bash_group,
      callback = function(args)
        if vim.bo[args.buf].filetype == "bash" then
          vim.defer_fn(function()
            apply_bash_syntax_colors()
            apply_security_markers(args.buf)
          end, 200)
        end
      end,
    })
  end,
}
