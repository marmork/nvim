-- ~/.config/nvim/lua/config/lint_setup.lua

local lint = require("lint")

-- Helper: detect Zope context via path
local function is_zope_file()
  local path = vim.api.nvim_buf_get_name(0)
  return path:match("WebApp") ~= nil
end

-- Dynamic Ruff args (always returns a table, no direct function reference)
local function get_ruff_args()
  local filename = vim.api.nvim_buf_get_name(0)

  if is_zope_file() then
    return {
      "check",
      "--ignore", "F706",
      "--builtins", "context,request,container",
      "--extend-ignore", "F821",
      "--stdin-filename", filename,
      "--output-format", "json",
      "-",
    }
  else
    return {
      "check",
      "--stdin-filename", filename,
      "--output-format", "json",
      "-",
    }
  end
end

-- ESLint Configuration
lint.linters.eslint.cmd = os.getenv("HOME") .. "/.npm-global/bin/eslint"
lint.linters.eslint.args = {
  "--format", "json",
  "--config", os.getenv("HOME") .. "/.eslint.config.js",
  vim.api.nvim_buf_get_name(0),
}
lint.linters.eslint.ignore_exitcode = true

-- Ruff Configuration (use wrapper function to produce table at runtime)
lint.linters.ruff.cmd = "ruff"
lint.linters.ruff.args = get_ruff_args()  -- evaluate once per load
lint.linters.ruff.ignore_exitcode = true

-- Filetype mapping
lint.linters_by_ft = {
  javascript = { "eslint" },
  typescript = { "eslint" },
  python = { "ruff" },
  sql = { "sqlfluff" },
}

-- Diagnostics visibility
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
})

-- Autolint on common events
local lint_augroup = vim.api.nvim_create_augroup("lint_group", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = lint_augroup,
  callback = function()
    -- Always re-evaluate args for Ruff before linting
    lint.linters.ruff.args = get_ruff_args()
    lint.try_lint()
  end,
})