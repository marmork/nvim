-- lua/plugins/git.lua
return {
  -- Gitsigns for git integration
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
    end
  },
  -- Neogit for Git
  {
    'git@github.com:NeogitOrg/neogit.git',
    cmd = 'Neogit',
    dependencies = 'plenary.nvim',
    config = true
  },
}