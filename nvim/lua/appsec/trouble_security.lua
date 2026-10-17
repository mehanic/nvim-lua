-- ========================================================================
-- 🔹 TROUBLE.NVIM: SECURITY DIAGNOSTICS + AUTO LINE HIGHLIGHT
-- ========================================================================

-- Список security-інструментів
local sec_sources = {
  "gosec",
  "bandit",
  "semgrep",
  "trivy",
  "gitleaks",
  "checkov",
  "tfsec",
  "kube-linter",
  "npm-groovy-lint",
  "helm_lint",
  "sqls",
}

-- Безпечна перевірка списку (сумісна з Neovim 0.9+)
local list_contains = vim.list_contains or vim.tbl_contains

local function is_security_source(src)
  return src and list_contains(sec_sources, src)
end

-- Namespace та highlight-група (Nord)
local sec_ns = vim.api.nvim_create_namespace("trouble_security_highlight")
vim.api.nvim_set_hl(0, "TroubleSecLineHighlight", {
  bg = "#3b4252",
  fg = "#bf616a",
  bold = true,
  link = "",
})

-- Застосувати/Оновити підсвітку
local function update_sec_highlights(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  vim.api.nvim_buf_clear_namespace(bufnr, sec_ns, 0, -1)
  local diags = vim.diagnostic.get(bufnr)
  for _, d in ipairs(diags) do
    if is_security_source(d.source) and d.severity <= 2 then
      vim.api.nvim_buf_add_highlight(bufnr, sec_ns, "TroubleSecLineHighlight", d.lnum, 0, -1)
    end
  end
end

-- Очистити підсвітку
local function clear_sec_highlights(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_clear_namespace(bufnr, sec_ns, 0, -1)
  end
end

-- Спільний фільтр для Trouble
local sec_filter = {
  severity = { min = vim.diagnostic.severity.WARN },
  fn = function(item)
    local src = item.source or (item.diagnostic and item.diagnostic.source)
    return is_security_source(src)
  end,
}

-- Авто-оновлення підсвітки при зміні діагностик (реальний час)
local sec_augroup = vim.api.nvim_create_augroup("AppSecHighlights", { clear = true })
vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = sec_augroup,
  callback = function(args)
    vim.schedule(function()
      update_sec_highlights(args.buf)
    end)
  end,
})

-- Безпечна очистка при закритті буфера
vim.api.nvim_create_autocmd("BufDelete", {
  group = sec_augroup,
  callback = function(args)
    clear_sec_highlights(args.buf)
  end,
})

-- Команда: :TroubleSec
vim.api.nvim_create_user_command("TroubleSec", function()
  update_sec_highlights()
  require("trouble").open("diagnostics", sec_filter)
end, { desc = "🛡️ Trouble: Security Diagnostics Only" })

-- ;xs — toggle для всього проєкту
vim.keymap.set("n", ";xs", function()
  require("trouble").toggle("diagnostics", sec_filter)
end, { desc = "️ Trouble: Toggle Security Diagnostics (Project)" })

-- ;xS — тільки для поточного буфера
vim.keymap.set("n", ";xS", function()
  local buf_filter = vim.tbl_extend("force", sec_filter, { buf = 0 })
  require("trouble").toggle("diagnostics", buf_filter)
end, { desc = "️ Trouble: Toggle Security Diagnostics (Current Buffer)" })
