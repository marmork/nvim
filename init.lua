-- set leader key
vim.g.mapleader = " "

-- load lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath})
end
vim.opt.rtp:prepend(lazypath)

-- load plugins from the 'plugins' folder
require("lazy").setup("plugins")

-- general neovim options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

-- Start Neovim in my writing folder
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.argc() == 0 then
            vim.cmd('NvimTreeToggle ' .. vim.fn.expand('~/Dokumente/Schreiben/'))
        end
    end,
    once = true
})

-- Automatic theme switching based on system mode
local function set_theme()
  local is_dark = vim.fn.has('night_mode') == 1
  if is_dark then
    vim.cmd('colorscheme catppuccin-mocha')
  else
    vim.cmd('colorscheme catppuccin-latte')
  end
end
set_theme()