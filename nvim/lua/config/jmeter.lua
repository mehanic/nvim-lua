return {
  -- ========================================================================
  -- 🔹 JMeter інтеграція: Neo-tree + Syntax Highlighting
  -- ========================================================================

  -- 1️⃣ Neo-tree для відображення файлів
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      -- Зберігаємо оригінальну функцію name, якщо вона є
      local original_name = opts.filesystem and opts.filesystem.components and opts.filesystem.components.name

      --  Додаємо JMeter логіку до компонентів neo-tree
      opts.filesystem = opts.filesystem or {}
      opts.filesystem.components = opts.filesystem.components or {}

      opts.filesystem.components.name = function(config, node, state)
        local name = node.name or ""
        local path = node.path or ""
        local text = name
        local hl = nil

        -- 🔹 JMeter files and directories
        if node.type == "file" then
          if name:match("%.jmx$") then
            text = " " .. name
            hl = "NeoTreeJMeterTest"
          elseif name:match("%.jtl$") then
            text = "󰔚 " .. name
            hl = "NeoTreeJMeterResults"
          elseif name:match("%.properties$") then
            text = " " .. name
            hl = "NeoTreeJMeterConfig"
          end
        elseif node.type == "directory" then
          local scan = vim.loop.fs_scandir(path)
          local has_jmx, has_jtl = false, false
          if scan then
            while true do
              local fname = vim.loop.fs_scandir_next(scan)
              if not fname then
                break
              end
              if fname:match("%.jmx$") then
                has_jmx = true
              elseif fname:match("%.jtl$") then
                has_jtl = true
              end
              if has_jmx and has_jtl then
                break
              end
            end
          end

          if has_jmx then
            text = " " .. name
            hl = "NeoTreeJMeterTestDir"
          elseif has_jtl then
            text = " " .. name
            hl = "NeoTreeJMeterResultsDir"
          elseif
            name:lower() == "jmeter"
            or name:lower() == "perf"
            or name:lower() == "performance"
            or path:match("/tests/jmeter/?$")
          then
            text = " " .. name
            hl = "NeoTreeJMeter"
          end
        end

        -- Якщо знайшли JMeter — повертаємо, інакше делегуємо оригінальній функції
        if hl then
          return { text = text, highlight = hl }
        elseif original_name then
          return original_name(config, node, state)
        end
        return { text = text, highlight = hl }
      end
    end,
  },

  -- 2️⃣ Автокоманди для підсвітки синтаксису .jmx файлів
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- 🔹 Autocmd для .jmx файлів
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "*.jmx",
        callback = function()
          vim.bo.filetype = "xml"

          -- кастомні JMeter-групи
          vim.cmd([[highlight JMeterTestPlan guifg=#c4a7e7 gui=bold]])
          vim.cmd([[highlight JMeterThreadGroup guifg=#f38ba8 gui=bold]])
          vim.cmd([[highlight JMeterSampler guifg=#fab387 gui=bold]])
          vim.cmd([[highlight JMeterResultCollector guifg=#ebbcba gui=bold]])
          vim.cmd([[highlight JMeterJSR223Sampler guifg=#9ccfd8 gui=bold]])

          -- XML
          vim.cmd([[highlight xmlTag guifg=#f38ba8 gui=bold]])
          vim.cmd([[highlight xmlTagName guifg=#ff9e64 gui=bold]])
          vim.cmd([[highlight xmlAttrName guifg=#f9e2af]])
          vim.cmd([[highlight xmlAttrValue guifg=#9ece6a]])
          vim.cmd([[highlight xmlComment guifg=#6c7086 gui=italic]])

          -- JMeter XML теги
          vim.cmd([[
            syntax match JMeterTestPlan "<TestPlan[^>]*>"
            syntax match JMeterThreadGroup "<ThreadGroup[^>]*>"
            syntax match JMeterSampler "<JSR223Sampler[^>]*>"
            syntax match JMeterResultCollector "<ResultCollector[^>]*>"
            syntax match JMeterJSR223Sampler "<JSR223Sampler[^>]*>"
          ]])

          -- Groovy/Java всередині JSR223Sampler
          vim.cmd([[highlight JMeterImport guifg=#ff9e64 gui=bold]])
          vim.cmd([[highlight JMeterType guifg=#9ece6a gui=bold]])
          vim.cmd([[highlight JMeterComment guifg=#6c7086 gui=italic]])
          vim.cmd([[highlight JMeterMethod guifg=#c4a7e7]])
          vim.cmd([[highlight JMeterVar guifg=#fab387 gui=bold]])
          vim.cmd([[highlight JMeterNumber guifg=#f5c2e7 gui=bold]])
          vim.cmd([[highlight JMeterString guifg=#9ece6a gui=bold]])

          vim.cmd([[
            syntax match JMeterImport "^\s*import\s\+\S\+" containedin=JMeterJSR223Sampler
            syntax match JMeterComment "//.*" containedin=JMeterJSR223Sampler
            syntax match JMeterType "\<String\>\|\<Long\>\|\<Integer\>\|\<Boolean\>" containedin=JMeterJSR223Sampler
            syntax match JMeterMethod "\<countDocuments\>\|\<insertOne\>\|\<setResponseData\>" containedin=JMeterJSR223Sampler
            syntax match JMeterVar "\<[A-Z_][A-Z0-9_]*\>" containedin=JMeterJSR223Sampler
            syntax match JMeterNumber "\<[0-9]\+\(\.[0-9]\+\)\?\>" containedin=JMeterJSR223Sampler
            syntax match JMeterString "\"[^\"]*\"" containedin=JMeterJSR223Sampler

            " ключові слова Groovy/Java
            syntax keyword GroovyKeyword if else for while return import class def
            highlight link GroovyKeyword Keyword

            " типи
            syntax keyword GroovyType String Integer Long Boolean Double List Map
            highlight link GroovyType Type

            " числові значення
            syntax match GroovyNumber "\v\d+(\.\d+)?"
            highlight link GroovyNumber Number

            " рядки
            syntax region GroovyString start=+"+ end=+"+ contains=GroovyEscape
            syntax match GroovyEscape "\\."
            highlight link GroovyString String

            " виклики методів (функцій)
            syntax match GroovyFunction "\v\w+\ze\("
            highlight link GroovyFunction Function

            " змінні JMeter
            syntax match JMeterVar "vars\.\w\+"
            highlight link JMeterVar Identifier
          ]])
        end,
      })
    end,
  },

  -- 3️⃣ Highlight групи для Neo-tree
  config = function()
    -- JMeter Highlights (Nord-палітра)
    vim.cmd([[highlight NeoTreeJMeter         guifg=#d3869b gui=bold]])
    vim.cmd([[highlight NeoTreeJMeterTest     guifg=#fabd2f gui=bold]])
    vim.cmd([[highlight NeoTreeJMeterResults  guifg=#fb4934 gui=bold]])
    vim.cmd([[highlight NeoTreeJMeterConfig   guifg=#83a598 gui=italic]])
    vim.cmd([[highlight NeoTreeJMeterTestDir  guifg=#fabd2f gui=bold]])
    vim.cmd([[highlight NeoTreeJMeterResultsDir guifg=#fb4934 gui=bold]])
  end,
}
