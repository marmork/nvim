-- ~/.config/nvim/lua/settings.lua
-- General Neovim options

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

-- Set theme automatically
local function set_theme()
  local is_dark = vim.fn.has("night_mode") == 1
  if is_dark then
    vim.cmd("colorscheme catppuccin-mocha")
  else
    vim.cmd("colorscheme catppuccin-latte")
  end
end
set_theme()
