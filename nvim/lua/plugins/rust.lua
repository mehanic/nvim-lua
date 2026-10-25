
-- ~/.config/nvim/lua/plugins/rust.lua

return {
  "mrcjkb/rustaceanvim",
  version = "^9",
  lazy = false,

  init = function()
    -- ============================================================
    -- RUSTACEANVIM / RUST-ANALYZER
    -- ============================================================
    vim.g.rustaceanvim = {
      tools = {
        test_executor = "background",
        code_actions = {
          ui_select_fallback = true,
        },
        hover_actions = {
          replace_builtin_hover = true,
        },
      },

      server = {
        on_attach = function(client, bufnr)
          local function map(lhs, command, desc)
            vim.keymap.set("n", lhs, function()
              vim.cmd.RustLsp(command)
            end, {
              buffer = bufnr,
              silent = true,
              desc = desc,
            })
          end

          map("<leader>ca", "codeAction", "Rust Code Action")
          map("<leader>ce", "explainError", "Explain Rust Error")
          map("<leader>cd", "renderDiagnostic", "Render Diagnostic")
          map("<leader>rr", "runnables", "Rust Runnables")
          map("<leader>rt", "testables", "Rust Testables")
          map("<leader>rd", "debuggables", "Rust Debuggables")
          map("<leader>rm", "expandMacro", "Expand Rust Macro")
          map("<leader>rc", "openCargo", "Open Cargo.toml")
          map("<leader>ro", "openDocs", "Open Rust Docs")

          vim.keymap.set("n", "<leader>rk", function()
            vim.cmd.RustLsp({ "moveItem", "up" })
          end, { buffer = bufnr, silent = true, desc = "Move Item Up" })

          vim.keymap.set("n", "<leader>rj", function()
            vim.cmd.RustLsp({ "moveItem", "down" })
          end, { buffer = bufnr, silent = true, desc = "Move Item Down" })
        end,

        default_settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              runBuildScripts = true,
            },

            check = {
              command = "clippy",
            },

            completion = {
              autoimport = {
                enable = true,
              },
              callable = {
                snippets = "fill_arguments",
              },
            },

            inlayHints = {
              bindingModeHints = { enable = false },
              chainingHints = { enable = true },
              closingBraceHints = {
                enable = true,
                minLines = 25,
              },
              closureReturnTypeHints = { enable = "with_block" },
              lifetimeElisionHints = { enable = "skip_trivial" },
              parameterHints = { enable = true },
              reborrowHints = { enable = "mutable" },
              renderColons = { enable = true },
              typeHints = {
                enable = true,
                hideClosureInitialization = false,
                hideNamedConstructor = false,
              },
            },
          },
        },
      },

      dap = {
        autoload_configurations = true,
      },
    }

    -- ============================================================
    -- RUST SYNTAX HIGHLIGHTING
    -- ============================================================
    local function apply_rust_colors()
      local function hl(groups, opts)
        for _, group in ipairs(groups) do
          vim.api.nvim_set_hl(0, group, opts)
        end
      end

      -- Keywords
      hl({ "@keyword", "@keyword.rust" }, {
        fg = "#c792ea", bold = true,
      })
      hl({ "@keyword.function", "@keyword.function.rust" }, {
        fg = "#FFD700", bold = true,
      })
      hl({ "@keyword.control", "@keyword.control.rust" }, {
        fg = "#ff757f",
      })
      hl({ "@keyword.operator", "@keyword.operator.rust" }, {
        fg = "#c792ea",
      })

      -- Macros
      hl({
        "@function.macro",
        "@function.macro.rust",
        "@lsp.type.macro",
        "@lsp.type.macro.rust",
        "@lsp.typemod.macro.defaultLibrary.rust",
        "@lsp.typemod.macro.library.rust",
        "rustMacro",
        "RustMacro",
      }, {
        fg = "#ff9e64", bold = true,
      })

      -- Function declarations
      hl({
        "@lsp.typemod.function.declaration.rust",
        "@lsp.type.function.rust",
        "rustFuncName",
        "RustFuncName",
        "rustFuncDecl",
      }, {
        fg = "#FFD700", bold = true,
      })

      -- Function calls and methods
      hl({
        "@function",
        "@function.call",
        "@function.method",
        "@lsp.type.method",
        "@lsp.type.method.rust",
      }, {
        fg = "#82aaff",
      })

      hl({ "@lsp.type.function" }, {
        fg = "#82aaff", bold = true,
      })

      -- Types
      hl({ "@type", "@type.rust" }, {
        fg = "#ffcb6b", bold = true,
      })
      hl({ "@type.builtin", "@type.builtin.rust" }, {
        fg = "#f78c6c", bold = true,
      })
      hl({ "@lsp.type.type", "@lsp.type.type.rust" }, {
        fg = "#ffcb6b", bold = true,
      })

      -- Variables and parameters
      hl({ "@variable", "@variable.rust" }, {
        fg = "#eeffff",
      })
      hl({ "@variable.builtin", "@variable.builtin.rust" }, {
        fg = "#f07178", bold = true,
      })
      hl({ "@parameter", "@parameter.rust" }, {
        fg = "#c792ea", italic = true,
      })
      hl({ "@lsp.type.parameter", "@lsp.type.parameter.rust" }, {
        fg = "#c792ea", italic = true,
      })
      hl({ "@lsp.type.variable", "@lsp.type.variable.rust" }, {
        fg = "#eeffff",
      })

      -- Constants and enum members
      hl({
        "@constant",
        "@constant.builtin",
        "@lsp.type.enumMember",
        "@lsp.type.enumMember.rust",
      }, {
        fg = "#f78c6c", bold = true,
      })

      -- Strings and numbers
      hl({ "@string", "@string.rust" }, {
        fg = "#c3e88d",
      })
      hl({ "@number", "@number.rust" }, {
        fg = "#f78c6c",
      })

      -- Comments
      hl({ "@comment", "@comment.rust" }, {
        fg = "#546e7a", italic = true,
      })
      hl({ "@comment.documentation", "@comment.documentation.rust" }, {
        fg = "#676e95", italic = true,
      })
      hl({ "@lsp.type.comment", "@lsp.type.comment.rust" }, {
        fg = "#546e7a", italic = true,
      })

      -- Attributes and lifetimes
      hl({ "@attribute", "@attribute.rust" }, {
        fg = "#7dcfff",
      })
      hl({ "@lifetime", "@lifetime.rust" }, {
        fg = "#ff757f", italic = true,
      })
      hl({ "@lsp.type.attribute", "@lsp.type.attribute.rust" }, {
        fg = "#7dcfff",
      })
      hl({ "@lsp.type.lifetime", "@lsp.type.lifetime.rust" }, {
        fg = "#ff757f", italic = true,
      })

      -- Punctuation and operators
      hl({
        "@punctuation.bracket",
        "@punctuation.delimiter",
        "@punctuation.special",
        "@operator",
      }, {
        fg = "#89ddff",
      })


            -- ... (твій існуючий код для Keywords, Macros, Functions тощо) ...

      -- =====================================================================
      -- 🔹 ДОДАТКОВІ RUST-СПЕЦИФІЧНІ ГРУПИ (Рекомендовано додати)
      -- =====================================================================

      -- 1. 🔴 Mutable змінні (НАЙКОРИСНІША ФІЧА!)
      -- rust-analyzer позначає змінні, оголошені через `let mut`, окремим токеном.
      -- Це дозволяє миттєво бачити, що стан змінної може змінитися.
      hl({ "@lsp.typemod.variable.mutable.rust" }, {
        fg = "#f07178", italic = true, -- Трохи інший відтінок або курсив для mut
      })

      -- 2. ⚡ Async / Await (Корутини)
      hl({ "@keyword.coroutine", "@keyword.coroutine.rust" }, {
        fg = "#c792ea", bold = true,
      })

      -- 3. 🏷️ Мітки (Labels) для циклів і break (наприклад: 'my_label: loop {})
      hl({ "@label", "@label.rust" }, {
        fg = "#ffcb6b", italic = true,
      })

      -- 4. 📦 Модулі та простори імен (std, crate, core)
      hl({ "@module", "@module.rust", "@lsp.type.namespace", "@lsp.type.namespace.rust" }, {
        fg = "#7dcfff", bold = true,
      })

      -- 5. 🔤 Екранування в рядках (\n, \x00) та аргументи форматування ({})
      hl({ "@string.escape", "@string.escape.rust" }, {
        fg = "#89ddff", bold = true,
      })
      hl({ "@string.special", "@string.special.rust" }, {
        fg = "#89ddff",
      })

      -- ... (продовження твого існуючого коду: Constants, Strings, Comments, Diagnostics) ...
      -- Diagnostics
      hl({ "DiagnosticError" }, {
        fg = "#f44747", bold = true,
      })
      hl({ "DiagnosticWarn" }, {
        fg = "#ffcb6b", bold = true,
      })
      hl({ "DiagnosticInfo" }, {
        fg = "#82aaff",
      })
      hl({ "DiagnosticHint" }, {
        fg = "#c3e88d",
      })
    end

    -- Reapply colors after the colorscheme changes.
    local group = vim.api.nvim_create_augroup(
      "RustCustomHighlight",
      { clear = true }
    )

    vim.api.nvim_create_autocmd("ColorScheme", {
      group = group,
      callback = apply_rust_colors,
    })

    vim.api.nvim_create_autocmd({ "FileType", "LspAttach" }, {
      group = group,
      callback = function(args)
        if args.event == "FileType" then
          if vim.bo[args.buf].filetype ~= "rust" then
            return
          end
        else
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= "rust_analyzer" then
            return
          end
        end

        vim.schedule(apply_rust_colors)
      end,
    })

    -- Apply immediately as well.
    vim.schedule(apply_rust_colors)
  end,
}
