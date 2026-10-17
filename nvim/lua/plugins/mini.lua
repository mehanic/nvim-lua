return {
  -- ✅ Оновлена назва репозиторію
  "nvim-mini/mini.files",
  version = false,
  dependencies = {
    -- ✅ Оновлена назва репозиторію
    { "nvim-mini/mini.icons", opts = {} },
  },
  config = function()
    require("mini.files").setup({
      content = {
        filter = nil,
        prefix = nil,
      },
      mappings = {
        close = "q",
        go_in = "l",
        go_in_plus = "L",
        go_out = "h",
        go_out_plus = "H",
        synchronize = "=",
        show_help = "g?",
      },
      options = {
        use_as_default_explorer = true,
      },
      windows = {
        max_number = math.huge,
        preview = false,
        width_focus = 40,
        width_nofocus = 15,
        width_preview = 40,
      },
    })
  end,
  keys = {
    {
      "<leader>e",
      function()
        require("mini.files").open()
      end,
      desc = "📂 Open mini.files",
    },
    {
      "<leader>E",
      function()
        require("mini.files").open(vim.api.nvim_buf_get_name(0))
      end,
      desc = "📂 Open mini.files (current file)",
    },
  },
}
