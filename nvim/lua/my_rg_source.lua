---@class blink-cmp-rg.Options
---@field prefix_min_len? number
---@field get_command? fun(context: blink.cmp.Context, prefix: string): string[]
---@field get_prefix? fun(context: blink.cmp.Context): string[]

local RgSource = {}

---@param opts blink-cmp-rg.Options
function RgSource.new(opts)
  opts = opts or {}

  return setmetatable({
    prefix_min_len = opts.prefix_min_len or 3,
    get_command = opts.get_command or function(_, prefix)
      return {
        "rg",
        "--no-config",
        "--json",
        "--word-regexp",
        "--ignore-case",
        "--",
        prefix .. "[\\w_-]+",
        vim.fs.root(0, ".git") or vim.fn.getcwd(),
      }
    end,
    get_prefix = opts.get_prefix or function(context)
      return context.line:sub(1, context.cursor[2]):match("[%w_-]+$") or ""
    end,
  }, { __index = RgSource })
end

function RgSource:get_completions(context, resolve)
  local prefix = self.get_prefix(context)

  if string.len(prefix) < self.prefix_min_len then
    resolve()
    return
  end

  vim.system(self.get_command(context, prefix), nil, function(result)
    if result.code ~= 0 then
      resolve()
      return
    end

    local items = {}
    local lines = vim.split(result.stdout, "\n")
    vim
      .iter(lines)
      :map(function(line)
        local ok, item = pcall(vim.json.decode, line)
        return ok and item or {}
      end)
      :filter(function(item)
        return item.type == "match"
      end)
      :map(function(item)
        return item.data.submatches
      end)
      :flatten()
      :each(function(submatch)
        items[submatch.match.text] = {
          label = submatch.match.text,
          kind = vim.lsp.protocol.CompletionItemKind.Text,
          insertText = submatch.match.text,
        }
      end)

    resolve({
      is_incomplete_forward = false,
      is_incomplete_backward = false,
      items = vim.tbl_values(items),
    })
  end)
end

return RgSource
