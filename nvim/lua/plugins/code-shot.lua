return {
  "niuiic/code-shot.nvim", -- ✅ Назва плагіна (автор niuiic) ------ sudo apt install silicon (або cargo install silicon)
  dependencies = {
    "nvim-lua/plenary.nvim", -- Часто потрібен для коректної роботи з системними викликами
  },
  keys = {
    -- 1. Звичайний режим (Normal mode): робить скріншот ВСЬОГО файлу
    {
      "<leader>p",
      function()
        require("code-shot").shot(function(context)
          vim.system(
            {
              "silicon",
              "--to-clipboard",
              "--pad-horiz",
              "0",
              "--pad-vert",
              "0",
              "--no-round-corner",
              "--theme",
              "Coldark-Dark",
              "--no-line-number",
              "--no-window-controls",
              context.file_path, -- Шлях до всього файлу
            },
            nil,
            function(result)
              if result.code == 0 then
                vim.notify(
                  "📸 Весь файл успішно скопійовано в буфер обміну!",
                  vim.log.levels.INFO
                )
              else
                vim.notify(
                  "❌ Помилка silicon: " .. (result.stderr or "невідомо"),
                  vim.log.levels.ERROR
                )
              end
            end
          )
        end)
      end,
      desc = "📸 Code Shot (весь файл)",
    },

    -- 2. Візуальний режим (Visual mode, mode = "x"): робить скріншот ВИДІЛЕНОГО фрагмента
    {
      "<leader>p",
      function()
        require("code-shot").shot(function(context)
          -- Безпечний вихід з візуального режиму (якщо у вас немає плагіна omega)
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)

          vim.system({
            "silicon",
            "--to-clipboard",
            "--pad-horiz",
            "0",
            "--pad-vert",
            "0",
            "--no-round-corner",
            "--theme",
            "Coldark-Dark",
            "--no-line-number",
            "--no-window-controls",
            "--language",
            context.file_type, -- Автоматичне визначення мови
          }, {
            stdin = context.selection, -- Передаємо тільки виділений текст
          }, function(result)
            if result.code == 0 then
              vim.notify(
                "📸 Виділений фрагмент успішно скопійовано!",
                vim.log.levels.INFO
              )
            else
              vim.notify("❌ Помилка silicon: " .. (result.stderr or "невідомо"), vim.log.levels.ERROR)
            end
          end)
        end)
      end,
      mode = "x",
      desc = "📸 Code Shot (виділений фрагмент)",
    },
  },
}
