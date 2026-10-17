return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    -- 1. Зберігаємо оригінальну функцію відображення імен, щоб не зламати інші файли
    local original_name = opts.filesystem and opts.filesystem.components and opts.filesystem.components.name

    opts.filesystem = opts.filesystem or {}
    opts.filesystem.components = opts.filesystem.components or {}

    -- 2. Хелпери для пошуку кореня Chef cookbook
    local function is_cookbook_root(dir_path)
      local fd = vim.loop.fs_scandir(dir_path)
      if not fd then
        return false
      end
      while true do
        local fname, ftype = vim.loop.fs_scandir_next(fd)
        if not fname then
          break
        end
        if ftype == "file" and (fname == "metadata.rb" or fname == "Berksfile" or fname == "Policyfile.rb") then
          return true
        end
      end
      return false
    end

    local function find_cookbook_root(current_path)
      local dir = current_path
      -- Безпечний підйом по дереву за допомогою vim.fs.dirname
      while dir and dir ~= "" and dir ~= "/" do
        if is_cookbook_root(dir) then
          return dir
        end
        dir = vim.fs.dirname(dir)
      end
      return nil
    end

    -- 3. Перевизначаємо компонент 'name'
    opts.filesystem.components.name = function(config, node, state)
      local name = node.name or ""
      local path = node.path or ""
      local text = name
      local hl = nil

      local root = find_cookbook_root(path)

      if root then
        -- ====================================================================
        -- 🔹 ФАЙЛИ CHEF COOKBOOK
        -- ====================================================================
        if node.type == "file" then
          if
            name == "metadata.rb"
            or name == "Berksfile"
            or name == "Policyfile.rb"
            or name == ".kitchen.yml"
            or name == "kitchen.yml"
          then
            text = " " .. name
            hl = "NeoTreeChef"
          elseif name:match("%.rb$") and path:find("/recipes/", 1, true) then
            text = " " .. name
            hl = "NeoTreeChefRecipe"
          elseif name:match("%.rb$") and path:find("/attributes/", 1, true) then
            text = " " .. name
            hl = "NeoTreeChefAttr"
          elseif name:match("%.rb$") and path:find("/resources/", 1, true) then
            text = " " .. name
            hl = "NeoTreeChefRes"
          elseif name:match("%.rb$") and path:find("/libraries/", 1, true) then
            text = " " .. name
            hl = "NeoTreeChefLib"
          elseif name:match("%.erb$") and path:find("/templates/", 1, true) then
            text = " " .. name
            hl = "NeoTreeChefTpl"
          elseif name:match("_spec%.rb$") or path:find("/spec/", 1, true) or path:find("/test/", 1, true) then
            text = "󰙨 " .. name
            hl = "NeoTreeChefTest"
          elseif name:match("%.json$") and path:find("/data_bags/", 1, true) then
            text = "󰘦 " .. name
            hl = "NeoTreeChefDataBag"
          end

        -- ====================================================================
        -- 🔹 ДИРЕКТОРІЇ CHEF COOKBOOK
        -- ====================================================================
        elseif node.type == "directory" then
          if path == root then
            text = " " .. name
            hl = "NeoTreeChef"
          elseif name == "recipes" then
            text = " " .. name
            hl = "NeoTreeChefRecipe"
          elseif name == "attributes" then
            text = " " .. name
            hl = "NeoTreeChefAttr"
          elseif name == "resources" then
            text = " " .. name
            hl = "NeoTreeChefRes"
          elseif name == "libraries" then
            text = " " .. name
            hl = "NeoTreeChefLib"
          elseif name == "templates" then
            text = " " .. name
            hl = "NeoTreeChefTpl"
          elseif name == "spec" or name == "test" then
            text = "󰙨 " .. name
            hl = "NeoTreeChefTest"
          elseif name == "data_bags" then
            text = "󰘦 " .. name
            hl = "NeoTreeChefDataBag"
          elseif name == "files" then
            text = " " .. name
            hl = "NeoTreeChefFiles"
          end
        end
      end

      -- 4. Повертаємо кастомний результат або делегуємо оригінальній функції
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
    require("neo-tree").setup(opts)

    local highlights = {
      -- Додаткові (з вашого коду)
      NeoTreeGroovy = { fg = "#E69F56", bold = true },
      NeoTreeConfig = { fg = "#6d8086", bold = true },

      -- Chef Cookbook
      NeoTreeChef = { fg = "#f09820", bold = true }, -- Помаранчевий (бренд Chef)
      NeoTreeChefRecipe = { fg = "#e67e22", bold = true },
      NeoTreeChefAttr = { fg = "#27ae60", bold = true }, -- Зелений
      NeoTreeChefRes = { fg = "#d35400", bold = true },
      NeoTreeChefLib = { fg = "#8e44ad", bold = true }, -- Фіолетовий
      NeoTreeChefTpl = { fg = "#3498db", bold = true }, -- Синій
      NeoTreeChefTest = { fg = "#c0392b", bold = true }, -- Червоний
      NeoTreeChefDataBag = { fg = "#16a085", bold = true }, -- Бірюзовий
      NeoTreeChefFiles = { fg = "#16a085", bold = true },
    }

    -- Функція застосування кольорів
    local function apply_chef_highlights()
      for group, hl_opts in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, hl_opts)
      end
    end

    -- Застосувати одразу
    apply_chef_highlights()

    -- Автоматично відновлювати кольори при зміні теми (ColorScheme)
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = apply_chef_highlights,
    })
  end,
}
