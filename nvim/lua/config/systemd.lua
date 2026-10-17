-- ========================================================================
-- 🔹 SYSTEMD UNIT FILES: Кастомна підсвітка (Nord-палітра)
-- Підтримує: .service, .timer, .socket, .target, .mount, .path,
--             .automount, .slice, .scope, .swap, .device
-- ========================================================================

-- 1️ Примусове розпізнавання filetype для systemd-файлів
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = {
    "*.service",
    "*.timer",
    "*.socket",
    "*.target",
    "*.mount",
    "*.path",
    "*.automount",
    "*.slice",
    "*.scope",
    "*.swap",
    "*.device",
    "*/systemd/system/*.conf",
    "*/systemd/user/*.conf",
  },
  callback = function()
    vim.bo.filetype = "systemd"
  end,
})

-- 2️⃣ Функція застосування кольорів
local function apply_systemd_syntax_colors()
  -- 🎨 Базова палітра (Nord)
  local section_color = "#88c0d0" -- nord8: секції [Unit], [Service]
  local key_color = "#ebcb8b" -- nord13: ключі ExecStart, After
  local path_color = "#a3be8c" -- nord14: шляхи /usr/bin/...
  local command_color = "#81a1c1" -- nord9: команди, аргументи
  local bool_color = "#b48ead" -- nord11: true/false, oneshot, simple
  local variable_color = "#d08770" -- nord12: змінні %i, %p, %n, %N
  local comment_color = "#4c566a" -- nord3: коментарі
  local text_color = "#d8dee9" -- nord4: звичайний текст

  -- ========================================================================
  --  1. TREESITTER CAPTURES (systemd parser)
  -- ========================================================================
  -- Секції: [Unit], [Service], [Install], [Timer]...
  vim.api.nvim_set_hl(0, "@label", {
    fg = section_color,
    bold = true,
    link = nil,
  })

  -- Ключі: ExecStart, After, Requires, Type, User...
  vim.api.nvim_set_hl(0, "@keyword", {
    fg = key_color,
    bold = true,
    link = nil,
  })

  -- Значення-шляхи: /usr/bin/python3, /etc/myapp/config
  vim.api.nvim_set_hl(0, "@string", {
    fg = path_color,
    link = nil,
  })

  -- Значення-команди та аргументи
  vim.api.nvim_set_hl(0, "@string.special", {
    fg = command_color,
    link = nil,
  })

  -- Булеві та enum-значення: true, false, oneshot, simple, notify, forking
  vim.api.nvim_set_hl(0, "@constant", {
    fg = bool_color,
    bold = true,
    link = nil,
  })

  -- Змінні systemd: %i, %p, %n, %N, %f, %t, %S
  vim.api.nvim_set_hl(0, "@variable", {
    fg = variable_color,
    bold = true,
    link = nil,
  })

  -- Коментарі: # це коментар
  vim.api.nvim_set_hl(0, "@comment", {
    fg = comment_color,
    italic = true,
    link = nil,
  })

  -- Оператори: =, +-, ++
  vim.api.nvim_set_hl(0, "@operator", {
    fg = "#89ddff",
    link = nil,
  })

  -- ========================================================================
  --  2. LEGACY VIM SYNTAX (ini-подібний фолбек)
  -- ========================================================================
  -- Секції [Unit], [Service] тощо
  vim.api.nvim_set_hl(0, "iniSection", {
    fg = section_color,
    bold = true,
    link = nil,
  })

  -- Ключі (ліва частина від =)
  vim.api.nvim_set_hl(0, "iniKey", {
    fg = key_color,
    bold = true,
    link = nil,
  })

  -- Значення (права частина від =)
  vim.api.nvim_set_hl(0, "iniString", {
    fg = path_color,
    link = nil,
  })

  -- Коментарі
  vim.api.nvim_set_hl(0, "iniComment", {
    fg = comment_color,
    italic = true,
    link = nil,
  })

  -- ========================================================================
  --  3. LSP SEMANTIC TOKENS (systemd-language-server, якщо є)
  -- ========================================================================
  vim.api.nvim_set_hl(0, "@lsp.type.section", {
    fg = section_color,
    bold = true,
    link = nil,
  })
  vim.api.nvim_set_hl(0, "@lsp.type.key", {
    fg = key_color,
    bold = true,
    link = nil,
  })
  vim.api.nvim_set_hl(0, "@lsp.type.value", {
    fg = path_color,
    link = nil,
  })
  vim.api.nvim_set_hl(0, "@lsp.type.comment", {
    fg = comment_color,
    italic = true,
    link = nil,
  })

  -- ========================================================================
  --  4. СПЕЦІАЛЬНІ HIGHLIGHT-ГРУПИ ДЛЯ SYSTEMD
  -- ========================================================================
  -- Відомі секції — підсвічуємо яскравіше
  vim.api.nvim_set_hl(0, "SystemdSectionUnit", {
    fg = "#88c0d0",
    bold = true,
    link = nil,
  })
  vim.api.nvim_set_hl(0, "SystemdSectionService", {
    fg = "#a3be8c",
    bold = true,
    link = nil,
  })
  vim.api.nvim_set_hl(0, "SystemdSectionInstall", {
    fg = "#b48ead",
    bold = true,
    link = nil,
  })
  vim.api.nvim_set_hl(0, "SystemdSectionTimer", {
    fg = "#ebcb8b",
    bold = true,
    link = nil,
  })

  -- Критичні ключі (Exec*, Restart, Type)
  vim.api.nvim_set_hl(0, "SystemdKeyExec", {
    fg = "#bf616a",
    bold = true,
    link = nil, -- червоний для Exec*
  })
  vim.api.nvim_set_hl(0, "SystemdKeyDependency", {
    fg = "#81a1c1",
    bold = true,
    link = nil, -- синій для After/Before/Requires
  })
  vim.api.nvim_set_hl(0, "SystemdKeyLifecycle", {
    fg = "#d08770",
    bold = true,
    link = nil, -- помаранчевий для Type/Restart
  })
end

-- ========================================================================
-- 🔹 3. АВТОКОМАНДИ
-- ========================================================================
local systemd_group = vim.api.nvim_create_augroup("SystemdSyntaxColors", { clear = true })

-- Застосувати одразу при відкритті systemd-файлу
vim.api.nvim_create_autocmd("FileType", {
  group = systemd_group,
  pattern = { "systemd", "dosini" },
  callback = function()
    -- Перевіряємо розширення, щоб не ламати звичайні .ini/.cfg файли
    local ext = vim.fn.expand("%:e")
    local systemd_exts = {
      "service",
      "timer",
      "socket",
      "target",
      "mount",
      "path",
      "automount",
      "slice",
      "scope",
      "swap",
      "device",
    }
    if vim.tbl_contains(systemd_exts, ext) then
      apply_systemd_syntax_colors()
    end
  end,
})

-- Перезастосовувати при зміні теми
vim.api.nvim_create_autocmd("ColorScheme", {
  group = systemd_group,
  callback = function()
    local ext = vim.fn.expand("%:e")
    local systemd_exts = {
      "service",
      "timer",
      "socket",
      "target",
      "mount",
      "path",
      "automount",
      "slice",
      "scope",
      "swap",
      "device",
    }
    if vim.tbl_contains(systemd_exts, ext) then
      apply_systemd_syntax_colors()
    end
  end,
})

-- Оновлювати при підключенні LSP (якщо є systemd-language-server)
vim.api.nvim_create_autocmd("LspAttach", {
  group = systemd_group,
  callback = function(args)
    if vim.bo[args.buf].filetype == "systemd" then
      vim.defer_fn(apply_systemd_syntax_colors, 200)
    end
  end,
})

-- ========================================================================
-- 🔹 4. ДОДАТКОВІ КОРИСНІ НАЛАШТУВАННЯ ДЛЯ SYSTEMD
-- ========================================================================
-- Налаштування відступів для systemd-файлів
vim.api.nvim_create_autocmd("FileType", {
  group = systemd_group,
  pattern = "systemd",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = false -- systemd prefer tabs
    vim.opt_local.commentstring = "# %s"
  end,
})

-- ========================================================================
-- 🔹 5. КОРИСНІ КОМАНДИ ТА KEYMAPS ДЛЯ SYSTEMD
-- ========================================================================
vim.api.nvim_create_user_command("SystemdReload", function()
  local file = vim.fn.expand("%:p")
  vim.fn.system("systemctl daemon-reload")
  vim.notify("🔄 systemctl daemon-reload executed", vim.log.levels.INFO)
end, { desc = "🔄 Reload systemd daemon" })

vim.api.nvim_create_user_command("SystemdStatus", function()
  local file = vim.fn.expand("%:t")
  if file:match("%.service$") then
    local unit = file
    vim.fn.system("systemctl status " .. unit .. " > /tmp/systemd-status.txt")
    vim.cmd("vsplit /tmp/systemd-status.txt")
    vim.bo.filetype = "log"
  else
    vim.notify("⚠️ Open a .service file first", vim.log.levels.WARN)
  end
end, { desc = "📊 Show systemctl status" })

vim.api.nvim_create_user_command("SystemdJournal", function()
  local file = vim.fn.expand("%:t")
  if file:match("%.service$") then
    local unit = file
    vim.fn.jobstart({
      "journalctl",
      "-u",
      unit,
      "-f",
      "--no-pager",
      "-n",
      "100",
    }, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        if data and #data > 0 then
          vim.notify(table.concat(data, "\n"), vim.log.levels.INFO, { title = "journalctl" })
        end
      end,
    })
  else
    vim.notify("️ Open a .service file first", vim.log.levels.WARN)
  end
end, { desc = "📋 Follow journalctl logs" })

-- Гарячі клавіші (тільки для systemd-буферів)
vim.api.nvim_create_autocmd("FileType", {
  group = systemd_group,
  pattern = "systemd",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    vim.keymap.set("n", "<leader>sd", ":SystemdReload<CR>", { buffer = buf, desc = "🔄 daemon-reload" })
    vim.keymap.set("n", "<leader>ss", ":SystemdStatus<CR>", { buffer = buf, desc = "📊 status" })
    vim.keymap.set("n", "<leader>sj", ":SystemdJournal<CR>", { buffer = buf, desc = "📋 journalctl" })
  end,
})
