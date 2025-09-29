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

-- Start Neovim in my writing folder
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      if pcall(require, "nvim-tree") then
          vim.cmd('NvimTreeToggle ' .. vim.fn.expand('~/Dokumente/Schreiben/'))
      end
    end
  end,
  once = true
})
vim.keymap.set('n', '<leader>n', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle File/Vault Tree' })

local writing_path = vim.fn.expand('~/Dokumente/Schreiben')
local coding_path = vim.fn.expand('~/repos')

vim.keymap.set('n', '<leader>ws', function()
  vim.cmd('cd ' .. writing_path)
  vim.cmd('NvimTreeToggle' .. writing_path)
end, { desc = 'Schreiben' })

vim.keymap.set('n', '<leader>wc', function()
  vim.cmd('cd ' .. coding_path)
  vim.cmd('NvimTreeToggle' .. coding_path)
end, { desc = 'Programmieren' })