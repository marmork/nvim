-- ~/.config/nvim/lua/config/format_setup.lua
local conform = require("conform")

conform.setup({
  -- Assign formatters to filetypes
  formatters_by_ft = {
    python = { "black" },  -- you could add "isort" before "black" if needed
    javascript = { "prettier" },
    typescript = { "prettier" },
    json = { "prettier" },
    markdown = { "prettier" },
    sh = { "shfmt" },
    sql = { "sqlfluff" },
  },

  -- Define formatter details
  formatters = {
    black = {
      command = "black",
      stdin = true,
      prepend_args = { "--line-length", "79" },
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