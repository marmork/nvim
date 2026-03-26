return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    -- Load standard VSCode snippets (e.g., from friendly-snippets if installed)
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Helper function to detect if the current file belongs to the Zope environment
    local function is_zope_file()
      local path = vim.api.nvim_buf_get_name(0)
      -- Check for common Zope path patterns
      return path:match("PerFact") ~= nil or 
             path:match("localhost") ~= nil or 
             path:match("/tmp/") ~= nil
    end

    -- Load Zope-specific snippets only when the context matches
    local function load_zope_snippets()
      if is_zope_file() then
        require("luasnip.loaders.from_vscode").lazy_load({
          -- stdpath("config") points to ~/.config/nvim/
          paths = { vim.fn.stdpath("config") .. "/lua/snippets/zope" }
        })
      end
    end

    -- Trigger snippet loading on buffer read or creation for Python and SQL
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
      pattern = { "*.py", "*.sql" },
      callback = load_zope_snippets,
    })

    local select_opts = { behavior = cmp.SelectBehavior.Select }

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = {
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<C-e>"] = cmp.mapping.abort(),
        
        -- Navigate through completion menu and jump through snippet placeholders
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
      },
      
      -- Define sources for autocompletion
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
      }),
    })
  end,
}