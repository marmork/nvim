-- lua/plugins/linting.lua
return {
  -- 1. Formatter (conform.nvim)
  {
      'stevearc/conform.nvim',
      -- Use BufWritePre to trigger the format check before writing the file.
      event = 'BufWritePre',
      cmd = { 'ConformInfo', 'ConformFormat' },
      config = function()
          -- Load the formatter setup
          require('config.format_setup')
      end,
  },

  -- 2. Linter (nvim-lint)
  {
      'mfussenegger/nvim-lint',
      -- Load when a buffer is read or opened
      event = 'BufReadPost',
      config = function()
          -- Load the linter setup
          require('config.lint_setup')
      end,
  },
  
  -- 3. Dependency: Plenary is still useful for various plugins
  'nvim-lua/plenary.nvim',
}