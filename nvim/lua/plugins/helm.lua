-- ~/.config/nvim/lua/plugins/helm.lua
return {
  "qvalentin/helm-ls.nvim",
  ft = "helm",
  dependencies = {
    -- Потрібен для treesitter-парсингу Helm-синтаксису
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    -- 🔹 Заміна шаблонів на virtual text з поточними значеннями
    conceal_templates = {
      enabled = true, -- experimental
    },
    -- 🔹 Підказки для indent/nindent
    indent_hints = {
      enabled = true,
      only_for_current_line = true, -- тільки для рядка з курсором
    },
    -- 🔹 Підсвічування поточного блоку
    action_highlight = {
      enabled = true,
    },
  },
  config = function(_, opts)
    -- Рекомендовано для правильного wrapping
    vim.opt.conceallevel = 2

    require("helm-ls").setup(opts)

    -- 🔹 Додаткові keymaps для Helm-файлів
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "helm",
      callback = function(event)
        local bufnr = event.buf
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, {
            buffer = bufnr,
            desc = desc,
            silent = true,
          })
        end

        -- Jump між {{- if }} і {{- end }} (вбудований, але явно)
        map("n", "%", "%", "Jump to matching block")

        -- LSP keymaps (якщо helm-ls налаштований)
        map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
        map("n", "K", vim.lsp.buf.hover, "Hover")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
      end,
    })
  end,
}
