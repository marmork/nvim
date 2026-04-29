return {
    "akinsho/toggleterm.nvim",
    version = "*",
    -- We define the keys here so lazy.nvim registers them immediately
    keys = {
      -- Shortcut to toggle the terminal (Ctrl + t)
      { "<C-t>", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
      -- Optional: Leader shortcut as a backup
      { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal (Leader)" },
    },
    config = function()
      require("toggleterm").setup({
        size = 15,
        -- Mapping inside the terminal to close it
        open_mapping = [[<C-t>]], 
        direction = 'horizontal',
        shade_terminals = true,
        start_in_insert = true,
        persist_size = true,
        close_on_exit = true,
        shell = vim.o.shell,
      })

      -- Terminal-only mappings
      function _G.set_terminal_keymaps()
        local opts = {buffer = 0}
        -- Exit terminal mode with Esc
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
        -- Quick window navigation from within the terminal
        vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
        vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
        vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
        vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
      end

      -- Apply mappings when a terminal opens
      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "term://*",
        callback = function()
          _G.set_terminal_keymaps()
        end,
      })
    end,
}