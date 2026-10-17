return {
  "nvim-neo-tree/neo-tree.nvim",
  -- Ми використовуємо opts як функцію, щоб безпечно об'єднати цей конфіг
  -- з вашими основними налаштуваннями neo-tree, якщо вони вже є.
  opts = function(_, opts)
    -- 1. Зберігаємо оригінальну функцію відображення імен, щоб не зламати інші файли
    local original_name = opts.filesystem and opts.filesystem.components and opts.filesystem.components.name

    opts.filesystem = opts.filesystem or {}
    opts.filesystem.components = opts.filesystem.components or {}

    -- 2. Перевизначаємо компонент 'name' для додавання Helm-логіки
    opts.filesystem.components.name = function(config, node, state)
      local name = node.name or ""
      local path = node.path or ""
      local text = name
      local hl = nil

      -- ========================================================================
      -- 🔹 HELM: Визначення іконок та підсвітки
      -- ========================================================================
      if name == "Chart.yaml" then
        text = "⎈ " .. name
        hl = "NeoTreeHelmChart"
      elseif name == "values.yaml" or name:match("^values.*%.ya?ml$") then
        text = "⎈ " .. name
        hl = "NeoTreeHelmValues"
      elseif name == "helmfile.yaml" then
        text = "⎈ " .. name
        hl = "NeoTreeHelmFile"
      elseif name == "requirements.yaml" then
        text = " " .. name
        hl = "NeoTreeHelmDeps"
      elseif name:match("secrets.*%.ya?ml$") then
        text = "󰌋 " .. name
        hl = "NeoTreeHelmSecrets"
      elseif path:match("/templates/") then
        text = "⎈ " .. name
        hl = "NeoTreeHelmTemplates"
      elseif path:match("/charts/") then
        text = " " .. name
        hl = "NeoTreeHelmCharts"
      elseif name:match("%.helm$") or name == "helm" or path:match("/helm") then
        text = "⎈ " .. name
        hl = "NeoTreeHelm"
      end

      -- 3. Повертаємо наш кастомний результат, або делегуємо оригінальній функції
      if hl then
        return { text = text, highlight = hl }
      elseif original_name then
        return original_name(config, node, state)
      end

      return { text = text }
    end
  end,

  -- ========================================================================
  -- 🔹 ВИЗНАЧЕННЯ ГРУП ПІДСВІЧУВАННЯ (Highlight Groups)
  -- ========================================================================
  config = function(_, opts)
    -- Завантажуємо neo-tree з нашими opts
    require("neo-tree").setup(opts)

    -- Сучасний спосіб визначення кольорів (швидший і чистіший за vim.cmd)
    local highlights = {
      NeoTreeHelm = { fg = "#1f9cf0", bold = true },
      NeoTreeHelmChart = { fg = "#1f9cf0", bold = true },
      NeoTreeHelmValues = { fg = "#fabd2f", bold = true },
      NeoTreeHelmFile = { fg = "#83a598", bold = true },
      NeoTreeHelmDeps = { fg = "#b8bb26", bold = true },
      NeoTreeHelmSecrets = { fg = "#fb4934", bold = true },
      NeoTreeHelmTemplates = { fg = "#d3869b", bold = true },
      NeoTreeHelmCharts = { fg = "#b16286", bold = true },
    }

    -- Застосовуємо кольори
    for group, hl_opts in pairs(highlights) do
      vim.api.nvim_set_hl(0, group, hl_opts)
    end

    -- Оновлюємо кольори автоматично при зміні теми (ColorScheme)
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        for group, hl_opts in pairs(highlights) do
          vim.api.nvim_set_hl(0, group, hl_opts)
        end
      end,
    })
  end,
}
