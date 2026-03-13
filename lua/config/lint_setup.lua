-- ~/.config/nvim/lua/config/lint_setup.lua
local lint = require("lint")

lint.linters_by_ft = {
  python = { "ruff" },
  sh     = { "shellcheck" },
  sql    = { "sqlfluff" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
  callback = function()
    lint.try_lint()
  end,
})