local M = {}

-- Безпечний slice для Neovim < 0.10
M.slice = vim.list_slice
  or function(tbl, s, e)
    local res = {}
    for i = s, e do
      res[#res + 1] = tbl[i]
    end
    return res
  end

-- Підказки для встановлення інструментів
M.get_install_hint = function(tool)
  local hints = {
    ["golangci-lint"] = "go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest",
    ["ruff"] = "pip install ruff",
    ["cargo"] = "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh",
    ["npx"] = "npm install -g npx eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin",
    ["phpstan"] = "composer require --dev phpstan/phpstan",
    ["radon"] = "pip install radon",
  }
  return hints[tool] or "Check official docs"
end

return M
