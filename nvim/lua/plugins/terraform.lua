return {
  "mvaldes14/terraform.nvim",
  ft = "terraform", -- 🔹 Ліниве завантаження: активується тільки в .tf файлах
  opts = {
    cmd = "rg", -- 🔹 Рекомендується ripgrep (набагато швидший за grep)
    program = "terraform", -- 🔹 Змініть на "opentofu", якщо використовуєте його
  },
  config = function(_, opts)
    require("terraform").setup(opts)

    -- 🔹 АВТО-ВАЛІДАЦІЯ: Перевіряє код при кожному збереженні (.tf або .tfvars)
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = { "*.tf", "*.tfvars" },
      callback = function()
        vim.cmd("TerraformValidate")
      end,
      desc = "Auto-validate terraform on save",
    })
  end,
  -- 🔹 Клавіші працюють ТІЛЬКИ в буферах з filetype=terraform
  keys = {
    { "<leader>tp", "<cmd>TerraformPlan<cr>", desc = "📝 Terraform Plan" },
    { "<leader>ti", "<cmd>TerraformInit<cr>", desc = "⚙️ Terraform Init" },
    { "<leader>te", "<cmd>TerraformFind<cr>", desc = "🔍 Find resource in State" },
    { "<leader>td", "<cmd>TerraformDocs<cr>", desc = "📖 Open Registry Docs" },
    { "<leader>tv", "<cmd>TerraformValidate<cr>", desc = "✅ Validate Config" },
  },
}
