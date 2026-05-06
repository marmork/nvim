return {
    "akinsho/toggleterm.nvim",
    version = "*",
    -- We define the keys here so lazy.nvim registers them immediately
    keys = {
      -- Shortcut to toggle the terminal
      { "<leader>t", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
      -- Optional: Leader shortcut as a backup
      { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal (Leader)" },
      {
        "<leader>ac",
        function()
          local ok, paths = pcall(require, "config.local_paths")
          local is_work = os.getenv("NVIM_MODE") == "work"

          if not is_work then
            vim.notify("Claude Sandbox is only available in 'work' mode.", vim.log.levels.WARN, { title = "Claude" })
            return
          end

          if not ok or not paths.claude_sandbox_path then
            vim.notify("Claude sandbox path not found in local_paths.lua", vim.log.levels.ERROR)
            return
          end

          local current_file = vim.fn.expand("%:p")
          local sandbox_dir = vim.fn.expand(paths.claude_sandbox_path)
          local extra_args = ""
          local workdir = ""

          -- Logic for Zope /tmp files (nvr)
          if current_file:match("^/tmp/") then
            -- Extract the specific folder, e.g., /tmp/tmp3vyebn12
            local tmp_folder = current_file:match("(/tmp/tmp[^/]+)")
            if tmp_folder then
              -- Surgically mount only this specific temp folder
              extra_args = string.format("-v %s:%s:rw", tmp_folder, tmp_folder)
              workdir = vim.fn.expand("%:p:h")
            end
          else
            -- Standard Logic for projects in ~/repos
            local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
            workdir = "/workspace/" .. project_name
          end

          -- Construct the command
          -- 1. Use -f for the correct compose file
          -- 2. Add extra_args for dynamic /tmp mounting
          -- 3. End with 'claude' to start the tool immediately
          local claude_cmd = string.format(
            "docker compose -f %s/docker-compose.yaml run --rm %s --workdir %s claude claude",
            sandbox_dir,
            extra_args,
            workdir
          )

          local Terminal = require("toggleterm.terminal").Terminal
          local claude_term = Terminal:new({
            cmd = claude_cmd,
            direction = "float",
            close_on_exit = true,
            float_opts = {
              border = "double",
            },
            -- Refresh buffers after Claude might have changed them
            on_close = function()
              vim.cmd("checktime")
            end,
          })
          claude_term:toggle()
        end,
        desc = "Toggle Claude Sandbox",
      }
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