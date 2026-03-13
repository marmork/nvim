-- ~/.config/nvim/lua/config/format_setup.lua
local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    python = {
      {
        command = "black",
        args = { "--line-length", "80", "-" },
        stdin = true,
      },
    },
    javascript = {
      {
        command = "prettier",
        args = { "--stdin-filepath", "$FILENAME", "--tab-width", "4" }
      }
    },
    typescript = { "prettier" },
    json = { "prettier" },
    markdown = { "prettier" },
    sh = { "shfmt" },
    sql = {
      { command = "sqlfluff",
      args = { "fix", "--dialect", "postgres", "--stdin" }, stdin = true }
    },
  },

  format_on_save = { timeout_ms = 500 },
})