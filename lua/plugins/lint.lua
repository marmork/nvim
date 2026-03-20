-- ~/.config/nvim/lua/plugins/lint.lua
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufWritePost", "InsertLeave", "TextChanged" },
  config = function()
    require("config.lint_setup")
  end,
}