return {
  'ellisonleao/gruvbox.nvim',
  priority = 1000,
  config = function()
    -- Optional configuration
    require("gruvbox").setup({
      terminal_colors = true,  -- Apply terminal colors
      -- italic = true,
      -- palette_overrides = {}, -- Custom color palette
      -- overrides = {},         -- Custom highlight group
      theme_style = "dark",   -- "dark", "hard", "light", "soft" (defaults to "dark")
    })
    vim.cmd.colorscheme 'gruvbox'
  end
}