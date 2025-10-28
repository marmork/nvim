-- Leader Key
vim.g.mapleader = " "

-- Lazy.nvim Bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Enable soft wrap only for specific file types (Markdown, TeX, Typst, Text)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "tex", "typst", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

-- Load plugins
require("lazy").setup("plugins")

-- Load configuration modules
require("config.keymaps")
require("config.settings")
require("config.workspaces")
