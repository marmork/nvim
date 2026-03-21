--- @file settings.lua
--- @brief Core Neovim behavior and UI settings.
---
--- This file configures:
--- 1. Global indentation (default 2 spaces).
--- 2. Python/JS overrides (4 spaces).
--- 3. Visual guides (ColorColumn at 80).
--- 4. UI elements (Line numbers, mouse support).

-- 1. Global Defaults
vim.opt.expandtab = true
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.showtabline = 2
vim.opt.signcolumn = "yes" -- Always show gutter to prevent text "jumping"

-- 2. FileType Specific Overrides (Python, JS, SQL)
local ft_group = vim.api.nvim_create_augroup("FileTypeOverrides", { clear = true })

-- Python
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  group = ft_group,
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.expandtab = true

    vim.opt_local.colorcolumn = "80"
    vim.opt_local.autoindent = true
    vim.opt_local.smartindent = false
    vim.opt_local.cindent = false
  end,
})

-- JS / TS dynamic indentation
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript" },
  group = ft_group,
  callback = function()
    local path = vim.api.nvim_buf_get_name(0)
    if path:match("WebApp") then
      -- Project-specific: 4 spaces
      vim.opt_local.shiftwidth = 4
      vim.opt_local.tabstop = 4
      vim.opt_local.expandtab = true
    else
      -- Default: 2 spaces
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
      vim.opt_local.expandtab = true
    end
  end,
})

-- SQL specifically (ensuring it stays at 2 spaces)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "sql",
  group = ft_group,
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})

-- 3. Softwrap for text-based formats
local softwrap_group = vim.api.nvim_create_augroup("SoftWrapTextFiles", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "tex", "plaintex" },
  group = softwrap_group,
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.showbreak = string.rep(" ", 2)
  end,
})

-- 4. Telescope Preview Window Behavior
vim.api.nvim_create_autocmd("User", {
  pattern = "TelescopePreviewerLoaded",
  callback = function(args)
    if not args or not args.data then return end
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.showbreak = string.rep(" ", 2)
  end,
})