local bash_snippets = dofile(vim.fn.expand("~/.config/nvim/snippets/bash_snippets/bash.lua"))
require("luasnip").add_snippets("bash", bash_snippets)
