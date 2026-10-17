-- ~/.config/nvim/lua/plugins/snacks.lua
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    picker = {
      enabled = true,
      sources = {
        explorer = {
          auto_close = true,
          hidden = true,
          layout = {
            preset = "default",
            preview = false,
          },
          actions = {
            -- 🔹 Копіювати шлях (меню з варіантами)
            copy_file_path = {
              action = function(_, item)
                if not item then
                  return
                end
                local vals = {
                  ["BASENAME"] = vim.fn.fnamemodify(item.file, ":t:r"),
                  ["EXTENSION"] = vim.fn.fnamemodify(item.file, ":t:e"),
                  ["FILENAME"] = vim.fn.fnamemodify(item.file, ":t"),
                  ["PATH"] = item.file,
                  ["PATH (CWD)"] = vim.fn.fnamemodify(item.file, ":."),
                  ["PATH (HOME)"] = vim.fn.fnamemodify(item.file, ":~"),
                  ["URI"] = vim.uri_from_fname(item.file),
                }
                local options = vim.tbl_filter(function(val)
                  return vals[val] ~= ""
                end, vim.tbl_keys(vals))
                if vim.tbl_isempty(options) then
                  Snacks.notify.warn("No values to copy")
                  return
                end
                table.sort(options)
                vim.ui.select(options, {
                  prompt = "Choose to copy to clipboard:",
                  format_item = function(list_item)
                    return ("%s: %s"):format(list_item, vals[list_item])
                  end,
                }, function(choice)
                  local result = vals[choice]
                  if result then
                    vim.fn.setreg("+", result)
                    Snacks.notify.info("Yanked `" .. result .. "`")
                  end
                end)
              end,
            },

            -- 🔹 Grep у директорії
            search_in_directory = {
              action = function(_, item)
                if not item then
                  return
                end
                local dir = vim.fn.fnamemodify(item.file, ":p:h")
                Snacks.picker.grep({
                  cwd = dir,
                  cmd = "rg",
                  args = {
                    "-g",
                    "!.git",
                    "-g",
                    "!node_modules",
                    "-g",
                    "!dist",
                    "-g",
                    "!build",
                    "-g",
                    "!coverage",
                    "-g",
                    "!.DS_Store",
                  },
                  show_empty = true,
                  hidden = true,
                  ignored = true,
                  follow = false,
                  supports_live = true,
                })
              end,
            },

            -- 🔹 Diff двох файлів
            diff = {
              action = function(picker)
                picker:close()
                local sel = picker:selected()
                if #sel > 1 then
                  vim.cmd("tabnew " .. sel[1].file)
                  vim.cmd("vert diffs " .. sel[2].file)
                  Snacks.notify.info("Diffing " .. sel[1].file .. " against " .. sel[2].file)
                else
                  Snacks.notify.info("Select two entries for the diff")
                end
              end,
            },

            -- 🔹 Відкрити зовні
            open_external = {
              action = function(_, item)
                if not item then
                  return
                end
                local cmd = vim.fn.has("mac") == 1 and "open" or vim.fn.has("win32") == 1 and "start" or "xdg-open"
                vim.fn.jobstart({ cmd, item.file }, { detach = true })
              end,
            },

            -- 🔹 Перейменувати
            rename = {
              action = function(_, item)
                if not item then
                  return
                end
                vim.ui.input({
                  prompt = "Rename to: ",
                  default = vim.fn.fnamemodify(item.file, ":t"),
                }, function(new_name)
                  if new_name and new_name ~= "" then
                    local new_path = vim.fn.fnamemodify(item.file, ":h") .. "/" .. new_name
                    vim.uv.fs_rename(item.file, new_path, function(err)
                      if err then
                        Snacks.notify.error("Rename failed: " .. err)
                      else
                        Snacks.notify.info("Renamed: " .. new_name)
                      end
                    end)
                  end
                end)
              end,
            },

            -- 🔹 Git stage/unstage
            git_toggle = {
              action = function(_, item)
                if not item then
                  return
                end
                local rel_path = vim.fn.fnamemodify(item.file, ":.")
                vim.fn.jobstart({ "git", "status", "--porcelain", "--", rel_path }, {
                  stdout_buffered = true,
                  on_stdout = function(_, data)
                    local status = table.concat(data, ""):gsub("%s+", "")
                    if status == "" or status:sub(1, 1) == "?" then
                      vim.fn.jobstart({ "git", "add", rel_path }, {
                        on_exit = function()
                          Snacks.notify.info("Staged: " .. rel_path)
                        end,
                      })
                    else
                      vim.fn.jobstart({ "git", "restore", "--staged", rel_path }, {
                        on_exit = function()
                          Snacks.notify.info("Unstaged: " .. rel_path)
                        end,
                      })
                    end
                  end,
                })
              end,
            },

            -- 🔹 Створити файл/директорію
            create = {
              action = function(_, item)
                local base = item and item.file or vim.fn.getcwd()
                vim.ui.input({ prompt = "New path (relative): " }, function(path)
                  if path and path ~= "" then
                    local full = vim.fn.fnamemodify(base .. "/" .. path, ":p")
                    if path:match("/$") then
                      vim.fn.mkdir(full, "p")
                      Snacks.notify.info("Directory created: " .. full)
                    else
                      vim.fn.mkdir(vim.fn.fnamemodify(full, ":h"), "p")
                      vim.uv.fs_open(full, "w", 438, function(err, fd)
                        if fd then
                          vim.uv.fs_close(fd)
                        end
                        if err then
                          Snacks.notify.error("Create failed: " .. err)
                        else
                          Snacks.notify.info("File created: " .. full)
                        end
                      end)
                    end
                  end
                end)
              end,
            },
          },

          -- 🔹 Keymaps для explorer
          win = {
            list = {
              keys = {
                ["y"] = "copy_file_path",
                ["s"] = "search_in_directory",
                ["D"] = "diff",
                ["o"] = "open_external",
                ["r"] = "rename",
                ["g"] = "git_toggle",
                ["N"] = "create",
                ["<C-x>"] = "open_with", -- змінено з <C-o>
              },
            },
          },
        },
      },
    },
  },

  -- 🔹 Keymaps та команди
  keys = {
    {
      "<leader>se",
      function()
        Snacks.picker.explorer()
      end,
      desc = "Snacks: Explorer",
    },
    {
      "<leader>sg",
      function()
        Snacks.picker.grep()
      end,
      desc = "Snacks: Grep",
    },
    {
      "<leader>sf",
      function()
        Snacks.picker.files()
      end,
      desc = "Snacks: Files",
    },
    {
      "<leader>ff",
      function()
        Snacks.picker.files()
      end,
      desc = "Find Files",
    },
    {
      "<leader>fg",
      function()
        Snacks.picker.grep()
      end,
      desc = "Grep",
    },
    {
      "<leader>fb",
      function()
        Snacks.picker.buffers()
      end,
      desc = "Buffers",
    },
    {
      "<leader>fr",
      function()
        Snacks.picker.recent()
      end,
      desc = "Recent",
    },
  },

  -- 🔹 Команди
  init = function()
    vim.api.nvim_create_user_command("SnacksExplorer", function()
      Snacks.picker.explorer()
    end, {})
    vim.api.nvim_create_user_command("SnacksGrep", function()
      Snacks.picker.grep()
    end, {})
    vim.api.nvim_create_user_command("SnacksFiles", function()
      Snacks.picker.files()
    end, {})
  end,
}
