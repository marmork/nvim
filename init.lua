-- Leader Key
vim.g.mapleader = " "

------------------------------------------------------------
-- Lazy.nvim Bootstrap
------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

------------------------------------------------------------
-- Safe LuaRocks integration
------------------------------------------------------------
local luarocks_path = vim.fn.expand("~/.luarocks/share/lua/5.1/?.lua")
local luarocks_cpath = vim.fn.expand("~/.luarocks/lib/lua/5.1/?.so")

-- Append instead of prepend
package.path = package.path .. ";" .. luarocks_path
package.cpath = package.cpath .. ";" .. luarocks_cpath

------------------------------------------------------------
-- Enable soft wrap only for specific file types
------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "tex", "typst", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

------------------------------------------------------------
-- Load plugins
------------------------------------------------------------
require("lazy").setup("plugins")

------------------------------------------------------------
-- Load configuration modules
------------------------------------------------------------
require("config.settings")
require("config.workspaces")
require("config.keymaps")
