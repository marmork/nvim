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
      local lsp = vim.lsp
      local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()

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

      -- Autostart servers lazily
      vim.api.nvim_create_autocmd("FileType", {
        pattern = vim.tbl_keys(ft_servers),
        callback = function(args)
          local ft = args.match
          local server_name = ft_servers[ft]
          if not server_name then return end

          -- Check if already active
          for _, client in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
            if client.name == server_name then return end
          end

          local server_config = vim.lsp.config[server_name]
          if not server_config then
            vim.notify("⚠️ No LSP config for " .. server_name, vim.log.levels.WARN)
            return
          end

          vim.lsp.start({
            name = server_name,
            capabilities = cmp_capabilities,
            on_attach = on_attach,
            cmd = server_config.cmd, -- Mason-registered binary
            root_dir = server_config.root_dir or vim.fn.getcwd(),
            filetypes = { ft },
          })
        end,
      })
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
