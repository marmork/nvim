-- Leader Key
vim.g.mapleader = " "

-- Lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Safe LuaRocks integration (only if luarocks dirs exist)
local luarocks_path = vim.fn.expand("~/.luarocks/share/lua/5.1/?.lua")
local luarocks_cpath = vim.fn.expand("~/.luarocks/lib/lua/5.1/?.so")
if vim.loop.fs_stat(vim.fn.expand("~/.luarocks")) then
  package.path = package.path .. ";" .. luarocks_path
  package.cpath = package.cpath .. ";" .. luarocks_cpath
end

-- Load plugins
require("lazy").setup("plugins")

-- Load configuration modules
require("config.settings")
require("config.workspaces")
require("config.keymaps")
