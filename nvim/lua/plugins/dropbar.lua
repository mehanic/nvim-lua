return {
  "Bekaboo/dropbar.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons", -- Для відображення іконок файлів
    -- "nvim-telescope/telescope-fzf-native.nvim", -- Розкоментуйте, якщо використовуєте fzf через telescope
  },
  config = function()
    require("dropbar").setup({
      -- 🎨 Стилі відображення
      style = "simple", -- 'minimal', 'simple', 'full'
      separator = "  ", -- Більш естетичний роздільник (можна залишити ' | ')

      -- 📁 Конфігурація filetype-специфічних налаштувань
      filetypes = {
        go = { enabled = true, icon = "", color = "#00ADD8" },
        ["go.tmpl"] = { enabled = true, icon = "", color = "#FFA500" },
        html = { enabled = true, icon = "", color = "#E34C26" },
        helm = { enabled = true, icon = "⚓", color = "#0000FF" },
        ["gitlab-ci.yml"] = { enabled = true, icon = "󰭘", color = "#E14E47" },
        python = { enabled = true, icon = "", color = "#3572A5" },
        javascript = { enabled = true, icon = "", color = "#f7df1e" },
        nodejs = { enabled = true, icon = "", color = "#8CC84B" },
        groovy = { enabled = true, icon = "", color = "#4298B8" },
        lua = { enabled = true, icon = "", color = "#000080" },
        sql = { enabled = true, icon = "", color = "#E34F26" },
        mongodb = { enabled = true, icon = "", color = "#47A248" },
        postgresql = { enabled = true, icon = "", color = "#336791" },
        mysql = { enabled = true, icon = "", color = "#F29111" },
        -- DevOps / Infra
        terraform = { enabled = true, icon = "", color = "#5c4ee5" },
        dockerfile = { enabled = true, icon = "", color = "#458ee6" },
        kubernetes = { enabled = true, icon = "󱃾", color = "#326ce5" },
        ansible = { enabled = true, icon = "", color = "#EE0000" },
        -- Config files
        json = { enabled = true, icon = "", color = "#f1e05a" },
        toml = { enabled = true, icon = "", color = "#9c4221" },
        yaml = { enabled = true, icon = "", color = "#cb171e" },
        ini = { enabled = true, icon = "", color = "#6d8086" },
        -- Docs / Markup
        markdown = { enabled = true, icon = "", color = "#083fa1" },
        rst = { enabled = true, icon = "", color = "#7f7f7f" },
        -- Shell / Scripting
        bash = { enabled = true, icon = "", color = "#89e051" },
      },

      -- 🧩 Компоненти breadcrumbs
      components = {
        file_name = { enabled = true, truncate = 40 },
        lsp_diagnostics = { enabled = true },
        line_column = { enabled = true },
        file_status = {
          enabled = true,
          format = function()
            return vim.bo.modified and "" or (vim.bo.readonly and "" or "")
          end,
        },
      },

      -- 🔗 Джерела для бару (динамічний вибір)
      bar = {
        sources = function(buf, _)
          local sources = require("dropbar.sources")
          local utils = require("dropbar.utils")

          -- Markdown: показувати заголовки
          if vim.bo[buf].ft == "markdown" then
            return { sources.path, sources.markdown }
          end

          -- Термінал: показувати ім'я терміналу
          if vim.bo[buf].buftype == "terminal" then
            return { sources.terminal }
          end

          -- Звичайні файли: LSP + Treesitter fallback
          return {
            sources.path,
            utils.source.fallback({
              sources.lsp,
              sources.treesitter,
            }),
          }
        end,
      },

      -- 🔍 Налаштування fzf для навігації
      fzf = {
        prompt = "%#Comment#🔍 %#Normal#",
        retain_inner_spaces = true,
        fuzzy_find_on_click = true,
        win_configs = {
          border = "rounded",
          height = 10,
          width = 60,
        },
      },

      -- 🔣 Іконки
      icons = {
        enable = true,
        kinds = {
          symbols = {
            Interface = " ",
            Struct = "󰌗 ",
            Method = " ",
            Field = " ",
            Function = "󰊕 ",
            Class = " ",
            Variable = " ",
            Constant = "󰏿 ",
          },
        },
      },

      -- 🧭 Навігація
      navigation = {
        enable = true,
        jump_to_file = true,
      },

      -- 🎨 Підсвічування
      highlight = {
        enable = true,
        active_color = "#FFD700",
      },
    })

    -- 🎨 Кастомні highlight groups (перевизначення кольорів іконок та активного контексту)
    local hl = vim.api.nvim_set_hl
    hl(0, "DropBarCurrentContext", { bg = "#3e4452", bold = true })
    hl(0, "DropBarIconKindFunction", { fg = "#61afef" })
    hl(0, "DropBarIconKindStruct", { fg = "#e5c07b" })
    hl(0, "DropBarIconKindInterface", { fg = "#f9d849" })
    hl(0, "DropBarIconKindMethod", { fg = "#b4f9f8" })
    hl(0, "DropBarIconKindField", { fg = "#e3e3e3" })
    hl(0, "DropBarIconKindVariable", { fg = "#e3e3e3" })
    hl(0, "DropBarIconKindConstant", { fg = "#f78c6c" })
    hl(0, "DropBarIconKindClass", { fg = "#f9d849" })
  end,
}
