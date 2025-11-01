-- ~/.config/nvim/lua/plugins/lsp.lua

return {
  -- 1. Mason
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },

  -- 2. Mason LSP Config
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig", "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "bashls",
          "pyright",
          "sqlls",
          "texlab",
          "ts_ls",
        },
        automatic_installation = true,
      })
    end,
  },

  -- 3. Mason Tool Installer (for linter/formatter)
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    -- Trigger only on setup
    config = function()
        -- Load the tool installation setup
        require('config.tool_installer')
    end,
  },

  -- 4. nvim-lspconfig
  {
    "neovim/nvim-lspconfig",
    config = function()
      local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()
      local on_attach = function(client, bufnr)
      end
      require('lspconfig.util').default_config = vim.tbl_deep_extend(
        'force', 
        require('lspconfig.util').default_config,
        {
          on_attach = on_attach,
          capabilities = cmp_capabilities,
        }
      )
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    lazy = false,
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
      })
    end,
  },
}
