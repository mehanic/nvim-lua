local python_snippets = dofile(vim.fn.expand("~/.config/nvim/snippets/python_snippet/python.lua"))
require("luasnip").add_snippets("python", python_snippets)
