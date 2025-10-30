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
-- Luarocks support (after Lazy.nvim bootstrap)
------------------------------------------------------------
-- Add LuaRocks paths so that `require` finds luarocks-installed modules
local function add_luarocks()
  local home = os.getenv("HOME")
  local paths = {
    home .. "/.luarocks/share/lua/5.1/?.lua",
    home .. "/.luarocks/share/lua/5.1/?/init.lua"
  }
  local cpaths = {
    home .. "/.luarocks/lib/lua/5.1/?.so"
  }

  for _, p in ipairs(paths) do
    if not package.path:find(p, 1, true) then
      package.path = package.path .. ";" .. p
    end
  end

  for _, p in ipairs(cpaths) do
    if not package.cpath:find(p, 1, true) then
      package.cpath = package.cpath .. ";" .. p
    end
  end
end
add_luarocks()

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
require("config.keymaps")
require("config.settings")
require("config.workspaces")
