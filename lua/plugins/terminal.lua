return {
    "akinsho/toggleterm.nvim",
    version = "*",
    -- We define the keys here so lazy.nvim registers them immediately
    keys = {
      -- Shortcut to toggle the terminal
      { "<leader>t", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
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

      -- Auto-Insert mode when entering Terminal; this ensures you can type immediately when you switch back to the terminal
      vim.api.nvim_create_autocmd({ "TermEnter", "BufEnter" }, {
        pattern = "term://*",
        callback = function()
          vim.cmd("startinsert")
        end,
      })

      -- Dynamic refresh and cwd sync; 
      vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "TermLeave" }, {
        callback = function()
          -- Sync Neovim's CWD to the current working directory
          -- This helps nvim-tree to stay in sync even if you 'cd' in the terminal
          if vim.bo.buftype == "" then
              vim.api.nvim_command("silent! cd .")
          end

          local ok, nvimtree_api = pcall(require, "nvim-tree.api")
          if ok then
            -- We force a root change to current directory and then reload
            nvimtree_api.tree.change_root(vim.fn.getcwd())
            nvimtree_api.tree.reload()
          end
        end,
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