-- ~/.config/nvim/lua/plugins/jinja2.lua
return {
  "geigerzaehler/tree-sitter-jinja2",
  -- Завантажувати тільки для Jinja2-файлів
  ft = { "jinja2", "htmljinja" },
  -- Або для розширень
  -- event = { "BufReadPre *.j2", "BufReadPre *.jinja", "BufReadPre *.jinja2" },
  config = true,
  -- Автоматична компіляція parser при встановленні
  build = function()
    require("lazy").build({ "tree-sitter-jinja2" })
  end,
}
