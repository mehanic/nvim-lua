-- ~/.config/nvim/lua/plugins/math-snippets.lua
return {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp", -- 🔑 Обов'язково для ECMAScript-регулярок
    dependencies = {
        "mathjiajia/nvim-math-snippets",
        -- Переконайтеся, що парсери встановлені (якщо у вас LazyVim, він це зробить)
        "nvim-treesitter/nvim-treesitter",
    },
    config = function()
        local ls = require("luasnip")
        
        -- Налаштування LuaSnip
        ls.setup({
            update_events = "TextChanged,TextChangedI",
            enable_autosnippets = true,
        })

        -- Завантаження сніпетів
        require("luasnip.loaders.from_lua").lazy_load({})
        
        -- Якщо ви використовуєте blink.cmp (як у LazyVim), 
        -- він підхопить сніпети автоматично.
    end,
}