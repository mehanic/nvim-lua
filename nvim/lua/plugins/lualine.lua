-- ~/.config/nvim/lua/plugins/lualine.lua
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function()
    return {
      options = {
        icons_enabled = true,
        -- 🔹 ВЛАСНА ТЕМА З ЯСКРАВИМ КОНТРАСТОМ РЕЖИМІВ
        theme = {
          normal = {
            a = { fg = "#282a36", bg = "#bd93f9", gui = "bold" }, -- фіолетовий (Normal)
            b = { fg = "#f8f8f2", bg = "#6272a4", gui = "bold" }, -- сіро-синій
            c = { fg = "#f8f8f2", bg = "#44475a" }, -- темний
            x = { fg = "#f8f8f2", bg = "#44475a" },
            y = { fg = "#f8f8f2", bg = "#6272a4", gui = "bold" },
            z = { fg = "#282a36", bg = "#bd93f9" },
          },
          insert = {
            a = { fg = "#282a36", bg = "#50fa7b", gui = "bold" }, -- зелений (Insert)
            b = { fg = "#f8f8f2", bg = "#6272a4" },
            c = { fg = "#f8f8f2", bg = "#44475a" },
          },
          visual = {
            a = { fg = "#282a36", bg = "#ff79c6", gui = "bold" }, -- рожевий (Visual)
            b = { fg = "#f8f8f2", bg = "#6272a4" },
            c = { fg = "#f8f8f2", bg = "#44475a" },
          },
          replace = {
            a = { fg = "#282a36", bg = "#ff5555", gui = "bold" }, -- червоний (Replace)
            b = { fg = "#f8f8f2", bg = "#6272a4" },
            c = { fg = "#f8f8f2", bg = "#44475a" },
          },
          command = {
            a = { fg = "#282a36", bg = "#ffb86c", gui = "bold" }, -- помаранчевий (Command)
            b = { fg = "#f8f8f2", bg = "#6272a4" },
            c = { fg = "#f8f8f2", bg = "#44475a" },
          },
          inactive = {
            a = { fg = "#6272a4", bg = "#44475a" },
            b = { fg = "#6272a4", bg = "#44475a" },
            c = { fg = "#6272a4", bg = "#44475a" },
          },
        },
        -- 🔹 Чіткі роздільники для кращого візуального поділу
        component_separators = { left = "│", right = "│" },
        section_separators = { left = "▓", right = "▓" },
        disabled_filetypes = {
          statusline = { "neo-tree", "TelescopePrompt", "TelescopeResults", "oil", "aerial", "snacks_picker" },
          winbar = {},
        },
        always_divide_middle = true,
        globalstatus = true,
        refresh = { statusline = 1000, tabline = 1000, winbar = 1000 },
      },
      sections = {
        lualine_a = {
          {
            "mode",
            icon = "", -- Nord-стиль іконка режиму
            padding = { left = 1, right = 1 },
          },
        },
        lualine_b = {
          { "branch", icon = "", padding = { left = 1, right = 0 } },
          { "diff", colored = true, symbols = { added = " ", modified = " ", removed = " " } },
        },
        lualine_c = {
          { "filename", file_status = true, path = 1, padding = { left = 1, right = 0 } },
          { "filetype", icon_only = true, colored = true, padding = { left = 1, right = 1 } },
        },
        lualine_x = {
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = { error = " ", warn = " ", info = " ", hint = " " }, -- Збережено Nord-іконки
            padding = { left = 1, right = 0 },
          },
          {
            function()
              local clients = vim.lsp.get_clients({ bufnr = 0 })
              if next(clients) == nil then
                return "  No LSP"
              end
              local names = vim.tbl_map(function(c)
                return c.name
              end, clients)
              return "  " .. table.concat(names, ", ")
            end,
            padding = { left = 1, right = 0 },
          },
          { "encoding", padding = { left = 1, right = 0 } },
          { "fileformat", symbols = { unix = "", dos = "", mac = "" } }, -- Збережено Nord-іконки
        },
        lualine_y = {
          { "progress", padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = {
          -- 🔹 ТІЛЬКИ ЧАС, БЕЗ ІКОНКИ ГОДИННИКА
          function()
            return os.date("%H:%M")
          end,
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = { "neo-tree", "quickfix", "fugitive", "nvim-dap-ui", "trouble" },
    }
  end,
}
