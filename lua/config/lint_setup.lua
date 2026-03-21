-- ~/.config/nvim/lua/config/lint_setup.lua

local lint = require("lint")

-- ESLint Configuration
lint.linters.eslint.cmd = os.getenv("HOME") .. "/.npm-global/bin/eslint"
lint.linters.eslint.args = {
  "--format", "json",
  "--config", os.getenv("HOME") .. "/.eslint.config.js",
  function()
    vim.api.nvim_buf_get_name(0)
  end,
}
lint.linters.eslint.ignore_exitcode = true

-- Ruff configuration
lint.linters.ruff.args = {
  "check",
  "--ignore", "F706",
  "--builtins", "context,request,container",
  "--extend-ignore", "F821",
  "--stdin-filename",
  function()
    return vim.api.nvim_buf_get_name(0)
  end,
  "--output-format", "json",
  "-",
}
lint.linters.ruff.ignore_exitcode = true

lint.linters_by_ft = {
  javascript = { "eslint" },
  typescript = { "eslint" },
  python = { "ruff" },
  sql = { "sqlfluff" },
}

-- Diagnostic settings to actually SEE the errors
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
})

-- Autolint on certain events
local lint_augroup = vim.api.nvim_create_augroup("lint_group", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = lint_augroup,
  callback = function()
    lint.try_lint()
  end,
})