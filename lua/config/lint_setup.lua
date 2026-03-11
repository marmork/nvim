--- @file lint_setup.lua
--- @brief Diagnostic engine for real-time code linting.

local lint = require('lint')

lint.linters_by_ft = {
  python = { 'flake8' },
  sh = { 'shellcheck' },
  sql = { 'sqlfluff' },
}

-- 1. Flake8 (Python 80-char alerts)
lint.linters.flake8 = {
  cmd = "/home/marcel/.local/share/nvim/mason/bin/flake8",
  args = {
    "--isolated",
    "--max-line-length=80",
    function() return vim.api.nvim_buf_get_name(0) end,
  },
  stdin = false,
  parser = require("lint.parser").from_pattern(
    [[^(%S+):(%d+):(%d+): (%w+): (.*)$]],
    { "filename", "lnum", "col", "code", "message" },
    { lnum = tonumber, col = tonumber }
  ),
}

-- 2. SQLFluff (Lower case & 2-space indent)
lint.linters.sqlfluff.args = {
  "lint",
  "--format=json",
  "--dialect=postgres",
  "-",
}

-- Triggering
vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
  callback = function()
    lint.try_lint()
  end,
})