-- ~/.config/nvim/lua/config/format_setup.lua
local conform = require("conform")

-- Helper: detect Zope context
local function is_zope_file()
  local path = vim.api.nvim_buf_get_name(0)
  return path:match("WebApp") ~= nil
end

conform.setup({
  -- Map filetypes to formatters
  formatters_by_ft = {
    python = { "black" },
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
      args = function()
        local filename = "$FILENAME"
        if is_zope_file() then
          -- Project-specific: 4 spaces, skip string normalization
          return { "--stdin-filename", filename, "--line-length", "80", "--skip-string-normalization", "-" }
        else
          -- Default Black config
          return { "--stdin-filename", filename, "-" }
        end
      end,
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
      command = os.getenv("HOME") .. "/.npm-global/bin/prettier",
      args = function()
        local filename = "$FILENAME"
        local base_args = { "--stdin-filepath", filename }

        if is_zope_file() then
          table.insert(base_args, "--tab-width")
          table.insert(base_args, "4")
        end

        return base_args
      end,
    },
  },

  format_on_save = {
    -- Increased timeout to ensure slower formatters don't hang
    timeout_ms = 2000,
    lsp_fallback = false,
  },
})