return {
  -- web icons
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- nvim-tree
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        -- Actions configuration: Open file will quit nvim-tree and resize the window
        actions = { open_file = { quit_on_open = true, resize_window = true } },
        filters = {
          -- FIX: Setting 'dotfiles' to true activates the built-in filter,
          -- which is required for the `toggle_hidden_filter()` API command 
          -- (mapped to <leader>h) to function correctly.
          dotfiles = true, 
        },
        -- on_attach is left empty, as keymaps are defined globally in keymaps.lua
        on_attach = function() end,
        -- Renderer settings
        renderer = { highlight_git = true },
      })

      -- Adding the autocommand to automatically update nvim-tree when cd
      vim.api.nvim_create_autocmd("DirChanged", {
        callback = function()
          -- 1. Load the nvim-tree View API to check the status
          local view_api = require("nvim-tree.view")
          
          -- Ensure that nvim-tree is open (visible)
          if view_api.is_visible() then
            -- 2. Load nvim-tree main API
            local nt_api = require("nvim-tree.api")
            
            -- Reload the tree and set the root to the new current directory
            nt_api.tree.change_root(vim.fn.getcwd())
          end
        end,
        group = vim.api.nvim_create_augroup("NvimTreeCdUpdate", { clear = true }),
      })
    end,
  },

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        autotag = { enable = true },
        ensure_installed = { "bash", "python", "javascript", "typescript", "lua", "markdown", "sql", "latex" },
        fold = { enable = true },
        highlight = { enable = true },
        indent = { enable = true },
        textobjects = { enable = true },
      })
    end,
  },

  -- completion ecosystem (plugins only; actual cmp.setup in keymaps.lua)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
    },
  },

  -- autopairs
  {
    "windwp/nvim-autopairs",
    config = function()
      local ok, autopairs = pcall(require, "nvim-autopairs")
      if not ok then return end
      autopairs.setup({})
      local ok_cmp_autopairs, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
      if ok_cmp_autopairs then
        local ok_cmp, cmp = pcall(require, "cmp")
        if ok_cmp and cmp then cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({})) end
      end
    end,
  },

  -- comment
  {
    "numToStr/Comment.nvim",
    config = function()
      local ok, c = pcall(require, "Comment")
      if ok then c.setup() end
    end,
  },
}
