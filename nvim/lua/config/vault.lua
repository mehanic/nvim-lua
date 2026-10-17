-- ========================================================================
-- 🔐 VAULT INTEGRATION FOR NEO-TREE
-- ========================================================================

-- 🔹 1. Highlight групи (завантажуються одразу)
local function set_vault_highlights()
  local highlights = {
    NeoTreeVaultConfig = { fg = "#b5b319", bold = true }, -- Жовтий для конфігів
    NeoTreeVaultPolicy = { fg = "#e91e63", bold = true }, -- Рожевий для політик
    NeoTreeVaultTLS = { fg = "#9c27b0", bold = true }, -- Фіолетовий для TLS
    NeoTreeVaultEnv = { fg = "#ffeb3b", bold = true }, -- Яскраво-жовтий для токенів
    NeoTreeVaultAudit = { fg = "#ff5722", bold = true }, -- Помаранчевий для аудит-логів
    NeoTreeVaultTerraform = { fg = "#7c4dff", bold = true }, -- Синій для Terraform
    NeoTreeVaultHelm = { fg = "#00acc1", bold = true }, -- Бірюзовий для Helm
    NeoTreeVaultPKI = { fg = "#3f51b5", bold = true }, -- Індиго для PKI
    NeoTreeVaultTpl = { fg = "#009688", bold = true }, -- Бірюзовий для шаблонів
    NeoTreeVault = { fg = "#b5b319", bold = true }, -- Fallback
  }

  for group, opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

-- Застосувати одразу
set_vault_highlights()

-- Оновлювати при зміні теми
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_vault_highlights,
})

-- ========================================================================
-- 🔹 2. РОЗШИРЕННЯ NEO-TREE (додаємо Vault-логіку до компонентів)
-- ========================================================================
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    -- Зберігаємо оригінальну функцію name, якщо вона є
    local original_name = opts.filesystem and opts.filesystem.components and opts.filesystem.components.name

    opts.filesystem = opts.filesystem or {}
    opts.filesystem.components = opts.filesystem.components or {}

    opts.filesystem.components.name = function(config, node, state)
      local name = node.name or ""
      local path = node.path or ""
      local text = name
      local hl = nil

      -- 🔐 Vault files and directories
      if node.type == "file" then
        -- Основний конфіг Vault
        if name == "vault.hcl" or name == "config.hcl" or name:match("%.hcl$") then
          text = " " .. name
          hl = "NeoTreeVaultConfig"
        -- Політики (HCL + JSON)
        elseif path:match("/policies/") and (name:match("%.hcl$") or name:match("%.json$")) then
          text = " " .. name
          hl = "NeoTreeVaultPolicy"
        -- TLS сертифікати / ключі
        elseif name:match("%.crt$") or name:match("%.pem$") or name:match("%.key$") then
          text = " " .. name
          hl = "NeoTreeVaultTLS"
        -- Vault env / токени
        elseif name == ".vault-token" or name == "vault.env" then
          text = " " .. name
          hl = "NeoTreeVaultEnv"
        -- Audit logs
        elseif name:match("audit.*%.log$") or name:match("vault_audit%.log$") then
          text = " " .. name
          hl = "NeoTreeVaultAudit"
        -- Terraform інтеграція
        elseif name:match("%.tf$") or name:match("terraform.*%.tfvars$") then
          text = "󱁢 " .. name
          hl = "NeoTreeVaultTerraform"
        -- Helm/Kubernetes values
        elseif (name == "values.yaml" or name == "helmfile.yaml") and path:match("vault") then
          text = " " .. name
          hl = "NeoTreeVaultHelm"
        end
      elseif node.type == "directory" then
        local vault_dirs = {
          "policies",
          "secrets",
          "auth",
          "approle",
          "userpass",
          "oidc",
          "transit",
          "kv",
          "database",
          "pki",
          "templates",
        }
        for _, d in ipairs(vault_dirs) do
          if name == d or path:match("/" .. d) then
            if name == "pki" then
              text = " " .. name
              hl = "NeoTreeVaultPKI"
            elseif name == "templates" then
              text = "󰙨 " .. name
              hl = "NeoTreeVaultTpl"
            else
              text = " " .. name
              hl = "NeoTreeVault"
            end
            break
          end
        end
      end

      -- Повертаємо результат або делегуємо оригінальній функції
      if hl then
        return { text = text, highlight = hl }
      elseif original_name then
        return original_name(config, node, state)
      end
      return { text = text, highlight = hl }
    end
  end,
}
