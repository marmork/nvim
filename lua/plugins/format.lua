-- ~/.config/nvim/lua/plugins/format.lua
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {},
  config = function()
    require("config.format_setup")
  end,
}