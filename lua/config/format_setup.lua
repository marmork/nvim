local conform = require("conform")

conform.setup({
  formatters = {
    black80 = {
      command = "black",
      args = { "--line-length", "80", "-" },
      stdin = true,
    },
    prettier4 = {
      command = "prettier",
      args = {
        "--stdin-filepath",
        "$FILENAME",
        "--tab-width",
        "4",
      },
      stdin = true,
    },
    sqlfluff_pg = {
      command = "sqlfluff",
      args = {
        "fix",
        "--dialect",
        "postgres",
        "-",
      },
      stdin = true,
    },
  },

  formatters_by_ft = {
    python = { "black80" },
    javascript = { "prettier4" },
    json = { "prettier" },
    markdown = { "prettier" }
    typescript = { "prettier4" },
    sh = { "shfmt" },
    sql = { "sqlfluff_pg" }
  },

  format_on_save = {
    timeout_ms = 500,
  },
})