-- ~/.config/nvim/lua/plugins/dispatch.lua

return {
  -- Plugin specification for vim-dispatch
  'tpope/vim-dispatch', 
  
  -- The :Dispatch command is provided by this plugin. 
  -- lazy.nvim will load the plugin when :Dispatch is first called.
  cmd = { 'Dispatch' },
}