--- @file format_setup.lua
--- @brief Automatic code correction on save.
---
--- This file handles:
--- 1. Trailing whitespace removal (All files).
--- 2. 4-space formatting for JS/TS via Prettier.
--- 3. Preventing "hard" formatting for Python to keep dictionaries expanded.

local conform = require('conform')

-- Helper for non-Mason tools
local function exists(name)
  local f = io.popen('command -v ' .. name)
  if f then
    local result = f:read('*a')
    f:close()
    return result ~= ''
  end
  return false
end

-- 1. Custom Formatter Definitions
local prettier_4_spaces = { "prettier", args = { "--stdin-filepath", "$FILENAME", "--tab-width", "4" } }

-- 2. Define Mappings
local formatters_by_ft = {
  ["*"] = { "trim_whitespace" },
  

  python = {}, 
  javascript = { prettier_4_spaces },
  typescript = { prettier_4_spaces },
  json = { "prettier" },
  markdown = { "prettier" },
  sh = { "shfmt" },
}

-- 3. External Tool Support
if exists('latexindent') then
  formatters_by_ft.tex = { 
    command = 'latexindent', 
    args = { '-m', '-l' }, 
    stdin = true
  }
  formatters_by_ft.latex = formatters_by_ft.tex
end

-- 4. Final Execution Setup
conform.setup({
  formatters_by_ft = formatters_by_ft,
  format_on_save = {
    lsp_fallback = true, 
    timeout_ms = 500,
    condition = function(bufnr)
      return vim.bo[bufnr].modifiable and vim.bo[bufnr].filetype ~= ''
    end,
  }
})