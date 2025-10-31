-- ~/.config/nvim/lua/plugins/lsp.lua
-- ✅ Neovim 0.11+ (vim.lsp.config API)
-- ✅ Mason + lazy LSP + nvim-cmp integration

return {
  -- 1. Mason Core
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    lazy = false,
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })
    end,
  },

  -- 2. Mason-LSPConfig
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    dependencies = { "neovim/nvim-lspconfig", "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "pyright",
          "ts_ls",
          "bashls",
          "marksman",
          "sqlls",
          "texlab",
        },
        automatic_installation = true,
      })
    end,
  },

  -- 3. LSP Setup (future-proof, filetype-triggered)
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()
      local util = require("lspconfig.util")

      -- Statische Server
      local servers = { "pyright", "ts_ls", "bashls", "sqlls", "texlab" }
      for _, name in ipairs(servers) do
        vim.lsp.config(name, {
          capabilities = cmp_capabilities,
        })
      end

      -- Marksman (Markdown)
      vim.lsp.config("marksman", {
        cmd                 = { "marksman", "server" },
        filetypes           = { "markdown" },
        single_file_support = true,
        capabilities        = cmp_capabilities,
        root_dir = function(fname)
          return util.find_git_ancestor(fname)
        end,
      })

      -- Aktivierung
      vim.lsp.enable({ "pyright", "ts_ls", "bashls", "sqlls", "texlab", "marksman" })
    end,
  },

  -- 4. Completion (nvim-cmp)
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
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
}
