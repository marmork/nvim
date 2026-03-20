-- ~/.config/nvim/lua/config/lint_setup.lua

local lint = require("lint")

lint.linters.eslint.cmd = os.getenv("HOME") .. "/.npm-global/bin/eslint"
lint.linters.eslint.args = {
  "--format", "json",
  "--config", os.getenv("HOME") .. "/.eslint.config.js",
  vim.api.nvim_buf_get_name(0),
}
lint.linters.eslint.ignore_exitcode = true

lint.linters_by_ft = {
  javascript = { "eslint" },
  typescript = { "eslint" },
  python = { "ruff" },
  sql = { "sqlfluff" },
}

-- Autolint on certain events
local lint_augroup = vim.api.nvim_create_augroup("lint_group", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged", "InsertLeave" }, {
  group = lint_augroup,
  callback = function()
    lint.try_lint()
  end,
})