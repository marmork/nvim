-- lua/plugins/editor.lua
return {
  -- Nvim-tree for file explorer
  {
    'nvim-tree/nvim-tree.lua',
    config = function()
      local api = require('nvim-tree.api')
      local on_attach = function(bufnr)
        vim.keymap.set('n', '<CR>', api.node.open.edit, { desc = "Open file in NvimTree", buffer = bufnr })
        vim.keymap.set('n', 'o', api.node.open.edit, { desc = "Open file in NvimTree", buffer = bufnr })
        vim.keymap.set('n', '<C-t>', api.node.open.tab, { desc = "Open in new tab", buffer = bufnr })
        vim.keymap.set('n', '<C-x>', api.node.open.horizontal, { desc = "Open in horizontal split", buffer = bufnr })
        vim.keymap.set('n', '<C-v>', api.node.open.vertical, { desc = "Open in vertical split", buffer = bufnr })
        vim.keymap.set('n', '<2-LeftMouse>', api.tree.open, { desc = "Toggle folder", buffer = bufnr })
        vim.keymap.set('n', '/', api.tree.find_file, { desc = "Find file", buffer = bufnr })
      end

      require('nvim-tree').setup({
        actions = {
          open_file = {
            quit_on_open = true,
            resize_window = true,
          },
        },
        on_attach = on_attach,
      })

      -- Visual selection with Shift+Arrow
      vim.keymap.set({'n', 'v'}, '<S-Up>', 'v<Up>', { noremap = true, silent = true })
      vim.keymap.set({'n', 'v'}, '<S-Down>', 'v<Down>', { noremap = true, silent = true })
      vim.keymap.set({'n', 'v'}, '<S-Left>', 'v<Left>', { noremap = true, silent = true })
      vim.keymap.set({'n', 'v'}, '<S-Right>', 'v<Right>', { noremap = true, silent = true })

      -- Move selected lines up/down
      vim.keymap.set('v', '<A-Down>', ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
      vim.keymap.set('v', '<A-Up>',   ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

      -- Copy/Cut/Paste with system clipboard
      vim.keymap.set('v', '<C-c>', '"+y', { noremap = true, silent = true })
      vim.keymap.set('v', '<C-x>', '"+d', { noremap = true, silent = true })
      vim.keymap.set('n', '<C-v>', '"+P', { noremap = true, silent = true })
      vim.keymap.set('v', '<C-v>', '"+P', { noremap = true, silent = true })

    end
  },
}