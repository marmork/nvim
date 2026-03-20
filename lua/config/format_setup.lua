-- ~/.config/nvim/lua/config/format_setup.lua
local conform = require("conform")

conform.setup({
  -- Map filetypes to formatters
  formatters_by_ft = {
    -- For Python, run trim_whitespace first, then black
    python = { "trim_whitespace", "black" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    json = { "prettier" },
    markdown = { "prettier" },
    sh = { "shfmt" },
    sql = { "sqlfluff" },
    -- Global fallback for all other filetypes
    ["*"] = { "trim_whitespace" },
  },

  formatters = {
    black = {
      command = "black",
      -- Using --stdin-filename as required by your local black version
      args = {
        "--stdin-filename", "$FILENAME",
        "--line-length", "80",
        "--skip-string-normalization", -- Keeps your single quotes
        "-",
      },
    },
    sqlfluff = {
      command = "sqlfluff",
      -- Ensure sqlfluff runs even if no .sqlfluff or .git directory is found
      require_cwd = false,
      args = {
        "fix",
        "--dialect", "postgres",
        "--force", -- Prevents interactive prompts
        "-",
      },
    },
    prettier = {
      command = "prettier",
      args = { 
        "--stdin-filepath", "$FILENAME", 
        "--single-quote", "true",
        "--tab-width", "4",
        "--trailing-comma", "none" 
      },
    },
  },

  format_on_save = {
    -- Increased timeout to ensure slower formatters don't hang
    timeout_ms = 2000,
    lsp_fallback = false,
  },
})