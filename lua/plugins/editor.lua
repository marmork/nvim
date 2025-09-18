-- lua/plugins/editor.lua
return {
  -- Nvim-tree for file explorer
  {
    'nvim-tree/nvim-tree.lua',
    config = function()
      local api = require('nvim-tree.api')

      -- Diese Funktion wird ausgeführt, sobald Nvim-Tree in einem Puffer geöffnet wird
      local on_attach = function(bufnr)
        -- Hier werden die Tastenbelegungen gesetzt, ohne die veraltete set_bufnr-Funktion
        vim.keymap.set('n', '<CR>', api.node.open.edit, { desc = "Open file in NvimTree", buffer = bufnr })
        vim.keymap.set('n', 'o', api.node.open.edit, { desc = "Open file in NvimTree", buffer = bufnr })
        vim.keymap.set('n', '<C-t>', api.node.open.tab, { desc = "Open in new tab", buffer = bufnr })
        vim.keymap.set('n', '<C-x>', api.node.open.horizontal, { desc = "Open in horizontal split", buffer = bufnr })
        vim.keymap.set('n', '<C-v>', api.node.open.vertical, { desc = "Open in vertical split", buffer = bufnr })
        vim.keymap.set('n', '<2-LeftMouse>', api.tree.open, { desc = "Toggle folder", buffer = bufnr })
        vim.keymap.set('n', '/', api.tree.find_file, { desc = "Find file", buffer = bufnr })
      end

      -- Hier wird die Hauptkonfiguration aufgerufen
      require('nvim-tree').setup({
        actions = {
          open_file = {
            quit_on_open = true,
            resize_window = true,
          },
        },
        on_attach = on_attach,
        -- Hier kannst du weitere Optionen hinzufügen
      })
    end
  },
}