return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")

    -- 🔹 ОБОВ'ЯЗКОВО: виклик setup()
    harpoon:setup({
      settings = {
        save_on_toggle = false,
        sync_on_ui_close = false,
        key = function()
          return vim.loop.cwd()
        end,
      },
    })

    -- 🔹 Розширення: відкриття файлів у сплітах/табах
    harpoon:extend({
      UI_CREATE = function(cx)
        vim.keymap.set("n", "<C-v>", function()
          harpoon.ui:select_menu_item({ vsplit = true })
        end, { buffer = cx.bufnr })

        vim.keymap.set("n", "<C-x>", function()
          harpoon.ui:select_menu_item({ split = true })
        end, { buffer = cx.bufnr })

        vim.keymap.set("n", "<C-t>", function()
          harpoon.ui:select_menu_item({ tabedit = true })
        end, { buffer = cx.bufnr })
      end,
    })

    -- 🔹 Підсвітка поточного файлу в списку
    local extensions = require("harpoon.extensions")
    harpoon:extend(extensions.builtins.highlight_current_file())

    -- ========================================================================
    -- 🔹 ГАРЯЧІ КЛАВІШІ
    -- ========================================================================
    local opts = { noremap = true, silent = true }

    -- Додати файл в список
    vim.keymap.set("n", "<leader>a", function()
      harpoon:list():add()
    end, { desc = "🎯 Harpoon: add file", unpack(opts) })

    -- Відкрити меню (Telescope UI)
    vim.keymap.set("n", "<C-e>", function()
      local harpoon_files = harpoon:list()
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require("telescope.pickers")
        .new({}, {
          prompt_title = "🎯 Harpoon Files",
          finder = require("telescope.finders").new_table({
            results = file_paths,
          }),
          previewer = require("telescope.config").values.file_previewer({}),
          sorter = require("telescope.config").values.generic_sorter({}),
        })
        :find()
    end, { desc = "🎯 Harpoon: open menu (Telescope)", unpack(opts) })

    -- Швидка навігація до файлів 1-4
    vim.keymap.set("n", "<C-h>", function()
      harpoon:list():select(1)
    end, { desc = "🎯 Harpoon: file 1", unpack(opts) })
    vim.keymap.set("n", "<C-t>", function()
      harpoon:list():select(2)
    end, { desc = "🎯 Harpoon: file 2", unpack(opts) })
    vim.keymap.set("n", "<C-n>", function()
      harpoon:list():select(3)
    end, { desc = "🎯 Harpoon: file 3", unpack(opts) })
    vim.keymap.set("n", "<C-s>", function()
      harpoon:list():select(4)
    end, { desc = "🎯 Harpoon: file 4", unpack(opts) })

    -- Навігація вперед/назад по списку
    vim.keymap.set("n", "<C-S-P>", function()
      harpoon:list():prev()
    end, { desc = "🎯 Harpoon: previous", unpack(opts) })
    vim.keymap.set("n", "<C-S-N>", function()
      harpoon:list():next()
    end, { desc = "🎯 Harpoon: next", unpack(opts) })
  end,
}
