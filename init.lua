-- Set leader key
vim.g.mapleader = " "

-- Load lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins from 'plugins' folder
require("lazy").setup("plugins")

-- General Neovim options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

-- Automatic theme switching based on system mode
local function set_theme()
  local is_dark = vim.fn.has("night_mode") == 1
  if is_dark then
    vim.cmd("colorscheme catppuccin-mocha")
  else
    vim.cmd("colorscheme catppuccin-latte")
  end
end
set_theme()

-- Start Neovim in writing folder (optional)
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      local ok, _ = pcall(require, "nvim-tree")
      if ok then
        vim.cmd("NvimTreeOpen " .. vim.fn.expand("~/Dokumente/Schreiben"))
      end
    end
  end,
  once = true,
})

vim.keymap.set("n", "<leader>n", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle File Tree" })

-- Define workspace paths
local writing_path = vim.fn.expand("~/Dokumente/Schreiben")
local coding_path = vim.fn.expand("~/repos")

-- Helper function to switch workspace
local function switch_workspace(mode)
  local path
  if mode == "writing" then
    path = writing_path
  elseif mode == "coding" then
    path = coding_path
  else
    print("❌ Unbekannter Modus: " .. tostring(mode))
    return
  end

  -- Close any open NvimTree before reopening
  vim.cmd("NvimTreeClose")
  vim.cmd("cd " .. path)
  vim.cmd("NvimTreeOpen " .. path)
  print("🗂  Wechsel zu: " .. path)
end

-- Keymaps for workspaces
vim.keymap.set("n", "<leader>ws", function() switch_workspace("writing") end,
  { desc = "Schreibmodus" })
vim.keymap.set("n", "<leader>wc", function() switch_workspace("coding") end,
  { desc = "Codemodus" })
