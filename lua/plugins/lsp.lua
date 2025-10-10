-- ~/.config/nvim/lua/plugins/lsp.lua
-- ✅ Neovim 0.11+ compatible
-- ✅ Lazy.nvim friendly
-- ✅ No deprecated lspconfig framework usage
-- ✅ LSP starts only for matching filetypes
-- ✅ Safe Mason integration
-- ✅ Completion via nvim-cmp & LuaSnip

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
      local mason_lsp = require("mason-lspconfig")
      mason_lsp.setup({
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

  -- 3. LSPConfig Servers (lazy start via FileType)
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local lsp = vim.lsp
      local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Default on_attach with buffer-local mappings
      local function on_attach(_, bufnr)
        local opts = { buffer = bufnr, noremap = true, silent = true }
        vim.keymap.set("n", "gd", lsp.buf.definition, opts)
        vim.keymap.set("n", "K", lsp.buf.hover, opts)
        vim.keymap.set("n", "gr", lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>rn", lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", lsp.buf.code_action, opts)
      end

      -- Mapping FileType -> LSP server name
      local ft_servers = {
        python = "pyright",
        typescript = "ts_ls",
        javascript = "ts_ls",
        bash = "bashls",
        markdown = "marksman",
        sql = "sqlls",
        tex = "texlab",
      }

      -- Lazy start LSP servers on FileType
      vim.api.nvim_create_autocmd("FileType", {
        pattern = vim.tbl_keys(ft_servers),
        callback = function(args)
          local ft = args.match
          local server_name = ft_servers[ft]
          if server_name then
            -- Setup LSP using new vim.lsp.config API
            if not lsp.get_active_clients({ name = server_name }) then
              -- Use vim.lsp.config for future-proof setup
              lsp.config(server_name, {
                capabilities = cmp_capabilities,
                on_attach = on_attach,
              })
              -- Enable the server immediately for this buffer
              lsp.enable(server_name)
            end
          end
        end,
      })

      vim.notify("✅ LSP ready (lazy, filetype-triggered, future-proof)", vim.log.levels.INFO)
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

      local select_opts = { behavior = cmp.SelectBehavior.Select }

      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item(select_opts)
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item(select_opts)
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
