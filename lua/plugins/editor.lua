return {

  -- Autopairs
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

  -- Bufferline: displays all loaded buffers as tabs
    {
      'akinsho/bufferline.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      version = "*",
      opts = {
          options = {
              show_buffer_close_icons = false,
              separator_style = 'thin', 
          },
      },
    },

  -- Comment
  {
    "numToStr/Comment.nvim",
    config = function()
      local ok, c = pcall(require, "Comment")
      if ok then c.setup() end
    end,
  },

  -- Completion ecosystem (plugins only; actual cmp.setup in keymaps.lua)
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

  -- Telescope & Live Grep Args
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { 
        "nvim-telescope/telescope-live-grep-args.nvim", 
        version = "^1.0.0" 
      },
    },
    config = function()
      local telescope = require("telescope")

      -- First setup telescope
      -- Standard search behavior is configured here
      telescope.setup({
        defaults = {
          -- Default configurations if needed
        },
      })

      -- Then load the extension
      telescope.load_extension("live_grep_args")
    end,
  },

  -- nvim-tree
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        -- Actions configuration: Open file will quit nvim-tree and resize the window
        actions = { 
          open_file = { quit_on_open = true, resize_window = true } 
        },
        filters = {
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
    opts = {
      ensure_installed = { 
        "bash", "python", "javascript", "typescript", "lua", 
        "markdown", "markdown_inline", "yaml", "sql", "latex",
        "vim", "vimdoc"
      },
      highlight = { enable = true },
      indent = { enable = true },
      -- 1. Tell Treesitter EXACTLY where to install the parsers
      parser_install_dir = vim.fn.stdpath("data") .. "/parsers",
    },
    config = function(_, opts)
      -- 2. IMPORTANT: Add the install directory to Neovim's runtime path 
      -- BEFORE setting up Treesitter, so Neovim can actually find the .so files
      vim.opt.runtimepath:append(opts.parser_install_dir)

      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if ok then
        configs.setup(opts)
      else
        -- Fallback for newer TS versions
        require("nvim-treesitter").setup(opts)
      end
    end,
  },

  -- Web icons
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Zen mode
  { 
    'folke/zen-mode.nvim',
    opts = {
      window = {
        width = 80, 
        height = 0.95,
        options = {
          wrap = true,
          linebreak = true,
          
          -- Optional, but recommended to keep the view clean:
          number = false,          -- Disables global ‘number’ setting
          relativenumber = false,  -- Disables global ‘relativenumber’ setting
        },
      },
      plugins = {
        options = { 
          enabled = true, 
          laststatus = 0, 
        },
      },
    },
    lazy = true,
    cmd = "ZenMode",
  },
}
