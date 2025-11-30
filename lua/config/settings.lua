-- General Neovim options

vim.opt.expandtab = true
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.showtabline = 2
vim.opt.tabstop = 2

-- Softwrap for text-based formats (Markdown, TeX, plain text)
-- Applies only to the actual buffer's filetype
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

-- Enable soft wrap inside Telescope preview windows.
-- Telescope previewers often use custom buffer/filetypes,
-- so filetype-based autocmds won't catch them.
vim.api.nvim_create_autocmd("User", {
  pattern = "TelescopePreviewerLoaded",
  callback = function(args)
    -- Defensive check: some Telescope events pass no additional data
    if not args or not args.data then
      return
    end

    -- Always enable softwrap in preview windows (safe and expected behavior)
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.showbreak = string.rep(" ", 2)
  end,
})
