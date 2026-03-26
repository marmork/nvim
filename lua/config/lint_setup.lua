-- ~/.config/nvim/lua/config/lint_setup.lua
local lint = require("lint")

-- 1. Helper for Zope context
local function is_zope_file()
  local path = vim.api.nvim_buf_get_name(0)
  -- Detect Zope via PerFact, localhost or /tmp/ paths
  return path:match("PerFact") ~= nil or path:match("localhost") ~= nil or path:match("/tmp/") ~= nil
end

-- 2. Arguments for ESLint (Lokal + Zope)
local function get_eslint_args()
  local args = {
    "--format", "json",
    "--config", os.getenv("HOME") .. "/.eslint.config.js",
  }

  if is_zope_file() then
    -- Special flags for Zope/Remote files
    table.insert(args, "--stdin")
    table.insert(args, "--stdin-filename")
    table.insert(args, vim.api.nvim_buf_get_name(0))
    table.insert(args, "--no-ignore")
  else
    -- Normal local behavior
    table.insert(args, vim.api.nvim_buf_get_name(0))
  end

  return args
end

-- 3. Arguments for Ruff (Lokal + Zope)
local function get_ruff_args()
  local filename = vim.api.nvim_buf_get_name(0)
  -- We always use stdin for Ruff as it is very stable
  local args = { "check", "--stdin-filename", filename, "--output-format", "json", "-" }

  if is_zope_file() then
    table.insert(args, 2, "--ignore")
    table.insert(args, 3, "F706")
    table.insert(args, 4, "--builtins")
    table.insert(args, 5, "context,request,container")
    table.insert(args, 6, "--extend-ignore")
    table.insert(args, 7, "F821")
  end
  return args
end

-- 4. Linter Commands setup
-- Use absolute path for ESLint to be sure
lint.linters.eslint.cmd = os.getenv("HOME") .. "/.npm-global/bin/eslint"
lint.linters.eslint.ignore_exitcode = true

lint.linters.ruff.cmd = "ruff"
lint.linters.ruff.ignore_exitcode = true

-- 5. Mapping
lint.linters_by_ft = {
  javascript = { "eslint" },
  typescript = { "eslint" },
  python = { "ruff" },
  sql = { "sqlfluff" },
}

-- 6. Diagnostics visibility
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
})

-- 7. Trigger Logic
local lint_augroup = vim.api.nvim_create_augroup("lint_group", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = lint_augroup,
  callback = function()
    local ft = vim.bo.filetype
    
    if ft == "python" then
      lint.linters.ruff.args = get_ruff_args()
      lint.try_lint("ruff")
    elseif ft == "javascript" or ft == "typescript" then
      lint.linters.eslint.args = get_eslint_args()
      lint.try_lint("eslint")
    elseif ft == "sql" then
      lint.try_lint("sqlfluff")
    end
  end,
})