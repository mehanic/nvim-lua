return {
  -- ========================================================================
  -- 🔹 ANSIBLE ІНТЕГРАЦІЯ: filetype detection + Neo-tree icons
  -- ========================================================================

  -- 1️ Авто-визначення filetype для Ansible YAML файлів
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- 🔹 Єдина автокоманда замість двох дублюючих
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        group = vim.api.nvim_create_augroup("AnsibleFiletype", { clear = true }),
        pattern = { "*.yml", "*.yaml" },
        callback = function(args)
          local bufnr = args.buf
          local filename = vim.api.nvim_buf_get_name(bufnr)
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 50, false)

          -- 🔍 Перевірка за ключовими словами Ansible
          local ansible_keywords = {
            "hosts:",
            "tasks:",
            "gather_facts:",
            "roles:",
            "ansible_",
            "galaxy_info",
            "platforms:",
          }

          for _, line in ipairs(lines) do
            for _, kw in ipairs(ansible_keywords) do
              if line:match(kw) then
                vim.bo[bufnr].filetype = "ansible"
                return
              end
            end
          end

          -- 🔍 Перевірка за шляхом (Ansible role структура)
          if
            filename:match("/roles/[^/]+/")
            and (
              filename:match("/meta/")
              or filename:match("/tasks/")
              or filename:match("/handlers/")
              or filename:match("/defaults/")
              or filename:match("/vars/")
              or filename:match("/molecule/")
              or filename:match("/templates/")
              or filename:match("/files/")
            )
          then
            vim.bo[bufnr].filetype = "ansible"
            return
          end

          -- 🔍 Перевірка за директоріями верхнього рівня
          if filename:match("/group_vars/") or filename:match("/host_vars/") or filename:match("/inventor") then
            vim.bo[bufnr].filetype = "ansible"
            return
          end

          -- За замовчуванням — звичайний YAML
          vim.bo[bufnr].filetype = "yaml"
        end,
      })
    end,
  },

  -- 2️⃣ Neo-tree інтеграція з Ansible іконками
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      -- Зберігаємо оригінальну функцію name
      local original_name = opts.filesystem and opts.filesystem.components and opts.filesystem.components.name

      opts.filesystem = opts.filesystem or {}
      opts.filesystem.components = opts.filesystem.components or {}

      opts.filesystem.components.name = function(config, node, state)
        local name = node.name or ""
        local path = node.path or ""
        local text = name
        local hl = nil

        -- ====================================================================
        -- 🔹 ANSIBLE: Визначення кореня проєкту та ролі
        -- ====================================================================
        local function is_ansible_root(dir_path)
          local fd = vim.loop.fs_scandir(dir_path)
          if not fd then
            return false
          end
          while true do
            local fname, ftype = vim.loop.fs_scandir_next(fd)
            if not fname then
              break
            end
            if
              ftype == "file"
              and (
                fname == "ansible.cfg"
                or fname:match("playbook.*%.ya?ml$")
                or fname == "site.yml"
                or fname == "main.yml"
              )
            then
              return true
            end
          end
          return false
        end

        local function find_ansible_root(dir_path)
          local dir = dir_path
          while dir and dir ~= "" do
            if is_ansible_root(dir) then
              return dir
            end
            dir = dir:match("(.+)/[^/]+$")
          end
          return nil
        end

        local function find_role_root(dir_path, root)
          if not root then
            return nil
          end
          local rel_path = dir_path:sub(#root + 2)
          return rel_path:match("^roles/([^/]+)/")
        end

        local ansible_node_icon = function(file_path, file_name, role_name)
          if role_name then
            local role_dirs = {
              tasks = { icon = "", hl = "NeoTreeAnsibleTasks" },
              handlers = { icon = "", hl = "NeoTreeAnsibleHandlers" },
              defaults = { icon = "", hl = "NeoTreeAnsibleDefaults" },
              vars = { icon = "", hl = "NeoTreeAnsibleVars" },
              templates = { icon = "", hl = "NeoTreeAnsibleTemplates" },
              files = { icon = "", hl = "NeoTreeAnsibleFiles" },
              tests = { icon = "", hl = "NeoTreeAnsibleTest" },
              meta = { icon = "", hl = "NeoTreeAnsibleMeta" },
              molecule = { icon = "", hl = "NeoTreeAnsibleMolecule" },
            }
            for dir_name, props in pairs(role_dirs) do
              if file_path:match("/roles/" .. role_name .. "/" .. dir_name) or file_name == dir_name then
                return props.icon .. " " .. file_name, props.hl
              end
            end
          end

          -- Inventory, group_vars, host_vars
          if file_path:match("/inventor") then
            return " " .. file_name, "NeoTreeAnsibleInv"
          elseif file_path:match("/group_vars") then
            return " " .. file_name, "NeoTreeAnsibleGroupVars"
          elseif file_path:match("/host_vars") then
            return " " .. file_name, "NeoTreeAnsibleHostVars"
          end

          -- Library, filter_plugins, collections
          if file_path:match("/library") then
            return " " .. file_name, "NeoTreeAnsibleLibrary"
          elseif file_path:match("/filter_plugins") then
            return " " .. file_name, "NeoTreeAnsibleFilter"
          elseif file_path:match("/collections") then
            return " " .. file_name, "NeoTreeAnsibleCollections"
          end

          return nil, nil
        end

        -- ====================================================================
        -- 🔹 ANSIBLE: Застосування іконок
        -- ====================================================================
        local root = find_ansible_root(path)
        local role = root and find_role_root(path, root)

        if node.type == "file" then
          -- Playbook файли
          if name:match("playbook.*%.ya?ml$") or name == "site.yml" or name == "main.yml" or name == "test.yml" then
            text = " " .. name
            hl = "NeoTreeAnsiblePlay"
          elseif name == "ansible.cfg" then
            text = " " .. name
            hl = "NeoTreeAnsibleCfg"
          elseif name == "requirements.yml" then
            text = " " .. name
            hl = "NeoTreeAnsibleGalaxy"
          else
            local icon, hl_group = ansible_node_icon(path, name, role)
            if icon then
              text = icon
              hl = hl_group
            end
          end
        elseif node.type == "directory" then
          local icon, hl_group = ansible_node_icon(path, name, role)
          if icon then
            text = icon
            hl = hl_group
          else
            -- Стандартні Ansible директорії
            local ansible_dirs_ext = {
              "roles",
              "playbooks",
              "group_vars",
              "host_vars",
              "inventories",
              "library",
              "filter_plugins",
              "collections",
              "molecule",
              "meta",
              "tests",
              "defaults",
              "vars",
              "handlers",
              "tasks",
              "files",
            }
            for _, d in ipairs(ansible_dirs_ext) do
              if name == d then
                text = " " .. name
                hl = "NeoTreeAnsible"
                break
              end
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
  },

  -- 3️⃣ Highlight групи для Ansible (Nord-палітра)
  config = function()
    -- Виправлено: видалено дублікати, оптимізовано кольори
    local highlights = {
      NeoTreeAnsible = { fg = "#c70e52", bold = true },
      NeoTreeAnsiblePlay = { fg = "#ffb347", bold = true },
      NeoTreeAnsibleMeta = { fg = "#e67e22", bold = true },
      NeoTreeAnsibleInv = { fg = "#27ae60", bold = true },
      NeoTreeAnsibleMolecule = { fg = "#3498db", bold = true },
      NeoTreeAnsibleGalaxy = { fg = "#9b59b6", bold = true },
      NeoTreeAnsibleCfg = { fg = "#6d8086", bold = true },
      NeoTreeAnsibleTasks = { fg = "#e67e22", bold = true },
      NeoTreeAnsibleHandlers = { fg = "#f39c12", bold = true },
      NeoTreeAnsibleDefaults = { fg = "#27ae60", bold = true },
      NeoTreeAnsibleVars = { fg = "#2ecc71", bold = true },
      NeoTreeAnsibleTemplates = { fg = "#3498db", bold = true },
      NeoTreeAnsibleFiles = { fg = "#95a5a6", bold = true },
      NeoTreeAnsibleVault = { fg = "#e74c3c", bold = true },
      NeoTreeAnsibleGroupVars = { fg = "#27ae60", bold = true },
      NeoTreeAnsibleHostVars = { fg = "#2ecc71", bold = true },
      NeoTreeAnsibleLibrary = { fg = "#f39c12", bold = true },
      NeoTreeAnsibleFilter = { fg = "#e74c3c", bold = true },
      NeoTreeAnsibleCollections = { fg = "#9b59b6", bold = true },
      NeoTreeAnsibleTest = { fg = "#1abc9c", bold = true },
    }

    for group, opts in pairs(highlights) do
      vim.api.nvim_set_hl(0, group, opts)
    end
  end,
}
