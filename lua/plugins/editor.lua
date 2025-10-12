return {
  -- web icons
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- nvim-tree
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        on_attach = function() end, -- no keymaps here
        actions = { open_file = { quit_on_open = true, resize_window = true } },
        renderer = { highlight_git = true },
      })
    end,
  },

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "bash", "python", "javascript", "typescript", "lua", "markdown", "sql", "latex" },
        highlight = { enable = true },
        indent = { enable = true },
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
