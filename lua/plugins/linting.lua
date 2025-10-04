-- lua/plugins/linting.lua
return {
  "nvimtools/none-ls.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  lazy = false,
  config = function()
    local null_ls = require("null-ls")
    local b = null_ls.builtins

    local function exists(name)
      local f = io.popen("command -v " .. name)
      if f then
        local result = f:read("*a")
        f:close()
        return result ~= ""
      end
      return false
    end

    local sources = {}

    if exists("black") then table.insert(sources, b.formatting.black) end
    if exists("prettier") then
      table.insert(sources, b.formatting.prettier) -- JS/TS
      table.insert(sources, b.formatting.prettier.with({ filetypes = { "markdown" } })) -- Markdown
    end
    if exists("shfmt") then table.insert(sources, b.formatting.shfmt) end
    if exists("shellcheck") then
      local helpers = require("null-ls.helpers")
      table.insert(sources, {
        name = "shellcheck",
        method = null_ls.methods.DIAGNOSTICS,
        filetypes = { "sh" },
        generator = helpers.generator_factory({
          command = "/usr/bin/shellcheck",  -- explicitly set path
          args = { "-f", "json", "$FILENAME" },
          to_stdin = false,
          format = "json",
          check_exit_code = function(code) return code <= 1 end,
          on_output = function(params)
            local diagnostics = {}
            for _, issue in ipairs(params.comments or {}) do
              table.insert(diagnostics, {
                row = issue.line,
                col = issue.column,
                end_col = issue.endColumn,
                source = "shellcheck",
                message = issue.message,
                severity = null_ls.diagnostics.severities["warning"],
              })
            end
            return diagnostics
          end,
        }),
      })
    end
    if exists("sqlfluff") then
      local helpers = require("null-ls.helpers")
      table.insert(sources, {
        name = "sqlfluff",
        method = null_ls.methods.DIAGNOSTICS,
        filetypes = { "sql" },
        generator = helpers.generator_factory({
          command = "sqlfluff",
          args = { "lint", "--dialect", "postgres", "--format", "json", "$FILENAME" },
          to_stdin = false,
          from_stderr = false,
          format = "json",
          check_exit_code = function(code) return code <= 1 end,
          on_output = function(params)
            local diagnostics = {}
            for _, issue in ipairs(params) do
              table.insert(diagnostics, {
                row = issue.line_no,
                col = issue.line_pos,
                end_col = issue.line_pos + 1,
                source = "sqlfluff",
                message = issue.description,
                severity = null_ls.diagnostics.severities["warning"],
              })
            end
            return diagnostics
          end,
        }),
      })
    end

    if exists("latexindent") then
      local helpers = require("null-ls.helpers")
      table.insert(sources, {
        name = "latexindent",
        method = null_ls.methods.FORMATTING,
        filetypes = { "tex", "latex" },
        generator = helpers.formatter_factory({
          command = "latexindent",
          args = { "-m", "-l" },
          to_stdin = true,
        }),
      })
    end

    if exists("typstfmt") then
      local helpers = require("null-ls.helpers")
      table.insert(sources, {
        name = "typstfmt",
        method = null_ls.methods.FORMATTING,
        filetypes = { "typst" },
        generator = helpers.formatter_factory({
          command = "typstfmt",
          args = { "--stdin" },
          to_stdin = true,
        }),
      })
    end

    null_ls.setup({
      sources = sources,
      on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ bufnr = bufnr })
            end,
          })
        end
      end,
    })
  end,
}
