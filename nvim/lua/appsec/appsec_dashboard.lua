return {
  "helino/neominimap.nvim",
  event = "VeryLazy", -- Завантажується після ініціалізації, щоб не гальмувати старт
  opts = {
    -- Базові налаштування мінімапи
    minimap = {
      width = 20,
      highlight = {
        background = "NeominimapBackground",
        border = "NeominimapBorder",
      },
    },
    integrations = {
      treesitter = true,
      diagnostics = true,
      gitsigns = true,
    },
  },
  config = function(_, opts)
    require("neominimap").setup(opts)

    local hl = vim.api.nvim_set_hl
    local keymap = vim.keymap.set
    local nm = "<leader>n" -- Префікс для мінімапи

    -- ========================================================================
    -- 🔹 1. HIGHLIGHT GROUPS (Nord Theme + AppSec)
    -- ========================================================================
    local highlights = {
      -- Основа
      NeominimapBackground = { bg = "#2e3440", fg = "#d8dee9" }, -- nord0 + nord4
      NeominimapBorder = { fg = "#4c566a" }, -- nord3
      NeominimapCursorLine = { bg = "#434c5e", bold = true }, -- nord2
      NeominimapCursorLineNr = { fg = "#88c0d0", bold = true }, -- nord8

      -- Treesitter (спрощена палітра для мінімапи)
      NeominimapFunction = { fg = "#88c0d0" }, -- cyan
      NeominimapKeyword = { fg = "#81a1c1" }, -- blue
      NeominimapString = { fg = "#a3be8c" }, -- green
      NeominimapComment = { fg = "#4c566a", italic = true },
      NeominimapType = { fg = "#b48ead" }, -- purple
      NeominimapConstant = { fg = "#d08770" }, -- orange

      -- Git & Diagnostics
      NeominimapGitAdd = { fg = "#a3be8c" },
      NeominimapGitChange = { fg = "#ebcb8b" },
      NeominimapGitDelete = { fg = "#bf616a" },
      NeominimapDiagnosticError = { fg = "#bf616a", bold = true },
      NeominimapDiagnosticWarn = { fg = "#ebcb8b", bold = true },
      NeominimapDiagnosticInfo = { fg = "#88c0d0" },
      NeominimapDiagnosticHint = { fg = "#b48ead" },

      -- 🛡️ SECURITY-SPECIFIC HIGHLIGHTS
      NeominimapSecCritical = { fg = "#bf616a", bg = "#3b4252", bold = true }, -- 🔴
      NeominimapSecHigh = { fg = "#d08770", bold = true }, -- 🟠
      NeominimapSecMedium = { fg = "#ebcb8b", bold = true }, -- 🟡
      NeominimapSecLow = { fg = "#a3be8c" }, -- 🟢
      NeominimapSecSecret = { fg = "#b48ead", bg = "#3b4252", bold = true }, -- 🔑
      NeominimapSecAudit = { fg = "#81a1c1", italic = true }, -- 📋
      NeominimapSecScanning = { fg = "#88c0d0", bold = true }, -- cyan
      NeominimapSecFound = { fg = "#bf616a", bold = true }, -- red
      NeominimapSecClean = { fg = "#a3be8c" }, -- green
    }

    for group, opts in pairs(highlights) do
      hl(0, group, opts)
    end

    -- ========================================================================
    -- 🔹 2. REAL-TIME SECURITY MARKERS IN BUFFER
    -- ========================================================================
    local sec_ns = vim.api.nvim_create_namespace("neominimap_security")

    local function apply_security_markers(bufnr)
      -- 🛡️ Оптимізація: не сканувати файли > 5000 рядків, щоб уникнути лагів
      if vim.api.nvim_buf_line_count(bufnr) > 5000 then
        return
      end

      vim.api.nvim_buf_clear_namespace(bufnr, sec_ns, 0, -1)
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

      for lnum, line in ipairs(lines) do
        local mark, hl_group = nil, nil

        -- 🔑 Hardcoded secrets
        if line:match("(password|secret|api[_-]?key|token|auth)[\"']?%s*[:=]%s*[\"']?[A-Za-z0-9+/=_-]{8,}") then
          mark, hl_group = "🔑", "NeominimapSecSecret"
        -- 💉 SQL injection
        elseif line:match("[\"']?SELECT.+%+.+[\"']?") or line:match("db%.ExecContext.*%+.+") then
          mark, hl_group = "💉", "NeominimapSecCritical"
        -- 🔓 Weak crypto
        elseif line:match("md5|sha1|des|rc4|ecb") and not line:match("//%s*no%s*-?sec") then
          mark, hl_group = "🔓", "NeominimapSecHigh"
        -- 🌐 XSS patterns
        elseif line:match("innerHTML|document%.write|eval%(") and line:match("user[_-]?input|request%[") then
          mark, hl_group = "🌐", "NeominimapSecHigh"
        -- 📋 Needs security review
        elseif line:match("//%s*SEC%-REVIEW:?|%s*TODO:%s*sec") then
          mark, hl_group = "📋", "NeominimapSecAudit"
        end

        if mark and hl_group then
          vim.api.nvim_buf_set_extmark(bufnr, sec_ns, lnum - 1, 0, {
            virt_text = { { mark .. " ", hl_group } },
            virt_text_pos = "right_align",
            priority = 1000,
          })
        end
      end
    end

    vim.api.nvim_create_autocmd({ "BufReadPost", "TextChanged" }, {
      pattern = { "*.go", "*.py", "*.rs", "*.tf", "*.yaml", "*.js", "*.ts" },
      callback = function(args)
        vim.schedule(function()
          apply_security_markers(args.buf)
        end)
      end,
    })

    -- ========================================================================
    -- 🔹 3. SECURITY LAYER CONTROLS
    -- ========================================================================
    local sec_layers = {
      diagnostics = true,
      secrets = true,
      crypto = true,
      review = true,
    }

    local function toggle_sec_layer(layer)
      sec_layers[layer] = not sec_layers[layer]
      require("neominimap").refresh()
      local status = sec_layers[layer] and "✅ ON" or "❌ OFF"
      vim.notify(
        string.format("Security layer '%s': %s", layer, status),
        vim.log.levels.INFO,
        { title = "🛡️ AppSec" }
      )
    end

    -- ========================================================================
    -- 🔹 4. SECURITY DASHBOARD (Floating Window)
    -- ========================================================================
    local function show_security_summary()
      local bufnr = vim.api.nvim_get_current_buf()
      local diagnostics = vim.diagnostic.get(bufnr)
      local counts = { critical = 0, high = 0, medium = 0, low = 0, secrets = 0 }
      local sec_sources = { "gosec", "bandit", "semgrep", "trivy", "gitleaks", "tfsec" }

      for _, diag in ipairs(diagnostics) do
        if vim.tbl_contains(sec_sources, diag.source) then
          if diag.severity == vim.diagnostic.severity.ERROR then
            counts.critical = counts.critical + 1
          elseif diag.severity == vim.diagnostic.severity.WARN then
            counts.high = counts.high + 1
          elseif diag.severity == vim.diagnostic.severity.INFO then
            counts.medium = counts.medium + 1
          else
            counts.low = counts.low + 1
          end
        end
      end

      -- Додатковий пошук секретів у тексті
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      for _, line in ipairs(lines) do
        if line:match("(password|secret|api[_-]?key|token)[\"']?%s*[:=]%s*[\"']?[A-Za-z0-9]{8,}") then
          counts.secrets = counts.secrets + 1
        end
      end

      local content = {
        " 🛡️ Security Summary ",
        "━━━━━━━━━━━━━━━━━━━━━━",
        string.format("🔴 Critical: %d", counts.critical),
        string.format("🟠 High:    %d", counts.high),
        string.format("🟡 Medium:  %d", counts.medium),
        string.format("🟢 Low:     %d", counts.low),
        string.format("🔑 Secrets: %d", counts.secrets),
        "",
        "💡 Швидкі дії:",
        "• <leader>nsd : toggle SAST",
        "• <leader>nsk : toggle secrets",
        "• :SecMinimapCritical",
      }

      local win = vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), true, {
        relative = "cursor",
        width = 35,
        height = #content,
        row = 1,
        col = 0,
        style = "minimal",
        border = "rounded",
        title = " 🛡️ AppSec Dashboard ",
        title_pos = "center",
      })

      vim.api.nvim_buf_set_lines(win.buffer, 0, -1, false, content)
      vim.bo[win.buffer].modifiable = false
      vim.bo[win.buffer].filetype = "markdown"

      -- Закриття вікна
      vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = win.buffer })
      vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = win.buffer })
    end

    -- ========================================================================
    -- 🔹 5. KEYBINDINGS & COMMANDS
    -- ========================================================================
    -- Глобальне керування
    keymap("n", nm .. "t", "<cmd>Neominimap Toggle<cr>", { desc = "🗺️ Minimap: toggle" })
    keymap("n", nm .. "o", "<cmd>Neominimap Enable<cr>", { desc = "🗺️ Minimap: enable" })
    keymap("n", nm .. "c", "<cmd>Neominimap Disable<cr>", { desc = "🗺️ Minimap: disable" })
    keymap("n", nm .. "r", "<cmd>Neominimap Refresh<cr>", { desc = "🗺️ Minimap: refresh" })
    keymap("n", nm .. "f", "<cmd>Neominimap Focus<cr>", { desc = "🗺️ Focus minimap" })

    -- Security controls
    keymap("n", nm .. "s", show_security_summary, { desc = "🛡️ Show security summary" })
    keymap("n", nm .. "sd", function()
      toggle_sec_layer("diagnostics")
    end, { desc = "🛡️ Toggle SAST diagnostics" })
    keymap("n", nm .. "sk", function()
      toggle_sec_layer("secrets")
    end, { desc = "🛡️ Toggle secret detection" })
    keymap("n", nm .. "sc", function()
      toggle_sec_layer("crypto")
    end, { desc = "🛡️ Toggle crypto warnings" })
    keymap("n", nm .. "sr", function()
      toggle_sec_layer("review")
    end, { desc = "🛡️ Toggle audit markers" })

    -- Команда для показу тільки CRITICAL
    vim.api.nvim_create_user_command("SecMinimapCritical", function()
      local cfg = vim.g.neominimap or {}
      cfg.diagnostic = cfg.diagnostic or {}
      cfg.diagnostic.severity = { min = vim.diagnostic.severity.ERROR }
      require("neominimap").refresh()
      vim.notify("🔴 Minimap: показуємо тільки CRITICAL", vim.log.levels.WARN)
    end, { desc = "🛡️ Show only critical security issues on minimap" })
  end,
}
