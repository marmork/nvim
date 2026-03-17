-- ~/.config/nvim/lua/config/format_setup.lua
local conform = require("conform")

conform.setup({
  -- Assign formatters to filetypes
  formatters_by_ft = {
    python = { "ruff_format" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    json = { "prettier" },
    markdown = { "prettier" },
    sh = { "shfmt" },
    sql = { "sqlfluff" },
  },

  -- Define formatter details
  formatters = {
    ruff_format = {
      prepend_args = {
        "format",
        "--line-length", "80",
        "--quote-style", "preserve", 
      },
    },
    prettier = {
      command = "prettier",
      stdin = true,
      prepend_args = { "--stdin-filepath", "$FILENAME", "--tab-width", "4" },
    },
    shfmt = { command = "shfmt", stdin = true },
    sqlfluff = {
      command = "sqlfluff",
      stdin = true,
      prepend_args = { "fix", "--dialect", "postgres", "--stdin" },
    },
  },

  format_on_save = {
    timeout_ms = 500,
  },
})