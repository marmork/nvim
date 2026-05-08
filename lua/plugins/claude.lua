local _claude_term = nil

return {
  "akinsho/toggleterm.nvim", -- Wir nutzen das gleiche Plugin
  keys = {
    {
      "<leader>ac",
      function()
        if _claude_term then
          _claude_term:toggle()
          return
        end

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

        -- Zope /tmp Logic
        if current_file:match("^/tmp/") then
          local tmp_folder = current_file:match("(/tmp/tmp[^/]+)")
          if tmp_folder then
            extra_args = string.format("-v %s:%s:rw", tmp_folder, tmp_folder)
            workdir = vim.fn.expand("%:p:h")
          end
        else
          -- Standard ~/repos Logic
          local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
          workdir = "/workspace/" .. project_name
        end

        local claude_cmd = string.format(
          "docker compose -f %s/docker-compose.yaml run --rm %s --workdir %s claude claude",
          sandbox_dir,
          extra_args,
          workdir
        )

        local Terminal = require("toggleterm.terminal").Terminal
        _claude_term = Terminal:new({
          cmd = claude_cmd,
          direction = "float",
          hidden = true,
          name = "Claude Sandbox",
          close_on_exit = true,
          float_opts = { border = "double" },
          on_open = function(term)
            vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-t>", [[<C-\><C-n><cmd>close<CR>]], {noremap = true, silent = true})
          end,
          on_exit = function()
            _claude_term = nil
          end,
          on_close = function()
            vim.cmd("checktime")
          end,
        })
        _claude_term:toggle()
      end,
      desc = "Claude Sandbox",
    },
  },
}