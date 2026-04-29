-- ~/.config/nvim/lua/config/format_setup.lua
local conform = require("conform")

-- Helper: detect Zope context
local function is_zope_file()
  local path = vim.api.nvim_buf_get_name(0)
  return path:match("PerFact") ~= nil
end

conform.setup({
  -- Map filetypes to formatters
  formatters_by_ft = {
    python = { "black" },
    javascript = function(bufnr)
      if is_zope_file(bufnr) then return { "trim_whitespace" } end
      return { "prettier" }
    end,
    typescript = function(bufnr)
      if is_zope_file(bufnr) then return { "trim_whitespace" } end
      return { "prettier" }
    end,
    json = { "prettier" },
    markdown = { "prettier" },
    sh = { "shfmt" },
    sql = { "sqlfluff" },
    ["*"] = { "trim_whitespace" },
  },

  formatters = {
    black = {
      prepend_args = function(self, bufnr)
        if is_zope_file(bufnr) then
          return {
            "--line-length", "79",
            "--skip-string-normalization",
            "--stdin-filename", "$FILENAME",
          }
        end
        return { "--stdin-filename", "$FILENAME" }
      end,
    },
    sqlfluff = {
       prepend_args = {
        "--dialect", "postgres",
        "--config", "indent_unit=2",
      },
      args = { "fix", "--force", "-" },
    },
    prettier = {
      command = vim.fn.expand("$HOME") .. "/.npm-global/bin/prettier",
      args = { "--stdin-filepath", "$FILENAME" },
    },
  },

  format_on_save = {
    -- Increased timeout to ensure slower formatters don't hang
    timeout_ms = 2000,
    lsp_fallback = false,
  },
})