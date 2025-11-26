-- ~/.config/nvim/lua/config/keymaps.lua
-- Central keymaps configuration

local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local ok_util, util_editor = pcall(require, "utils.editor")

---------------------------------------------------------------------
-- CORE VIM FIX: Ensure native commands are restored (recommended)
---------------------------------------------------------------------
-- Re-map native commands to themselves to prevent plugins from overriding them
map('n', 'gg', 'gg', { desc = "Go to first line (Native)" })
map('n', 'G', 'G', { desc = "Go to last line (Native)" })

---------------------------------------------------------------------
-- Workspaces & Layout (Master Setup Function)
---------------------------------------------------------------------

map('n', '<leader>w', '<cmd>ZenMode<CR>', { desc = 'Toggle Zen Mode (Central Writing)' })

local ok_ws, ws = pcall(require, "config.workspaces")
if ok_ws and ws then
  map("n", "<leader>ws", function() 
    ws.switch("writing")
    -- vim.cmd("ZenMode")
  end, { desc = "Writing Mode" })
  
  map("n", "<leader>wc", function() ws.switch("coding") end, { desc = "Coding Mode" })
end

---------------------------------------------------------------------
-- File tree toggle
---------------------------------------------------------------------
-- File tree toggle (for hidden files)
map("n", "<leader>hf", "<cmd>lua require('nvim-tree.api').tree.toggle_hidden_filter()<CR>", { desc = "Toggle NvimTree Hidden Files" })
map("n", "<leader>n", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle File Tree" })

-- Ensure Enter opens files inside NvimTree
vim.api.nvim_create_autocmd("FileType", {
  pattern = "NvimTree",
  callback = function()
    local api = require("nvim-tree.api")
    vim.keymap.set("n", "<CR>", api.node.open.edit, { buffer = true, desc = "NvimTree: Open file or folder" })
  end,
})

---------------------------------------------------------------------
-- Window Navigation Fix (Ctrl + H/J/K/L)
---------------------------------------------------------------------
-- This ensures jumping between splits (like NvimTree and main buffer) works reliably.
map('n', '<C-h>', '<C-w>h', { desc = 'Window: Go Left (<C-h>)' })
map('n', '<C-l>', '<C-w>l', { desc = 'Window: Go Right (<C-l>)' })
map('n', '<C-j>', '<C-w>j', { desc = 'Window: Go Down (<C-j>)' })
map('n', '<C-k>', '<C-w>k', { desc = 'Window: Go Up (<C-k>)' })

---------------------------------------------------------------------
-- Buffer Navigation
---------------------------------------------------------------------
-- Use <leader>y (previous) and <leader>x (next) for quick buffer switching.
map("n", "<leader>y", "<cmd>bprevious<CR>", { desc = "Buffer Previous (<leader>y)" })
map("n", "<leader>x", "<cmd>bnext<CR>", { desc = "Buffer Next (<leader>x)" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Buffer Close (<leader>bd)" })

---------------------------------------------------------------------
-- Editor convenience (visual selection, move lines, clipboard)
---------------------------------------------------------------------
-- 1. Visual selection (Shift + Arrows)
map({ "n", "v" }, "<S-Up>", "v<Up>", { desc = "Visual select up" })
map({ "n", "v" }, "<S-Down>", "v<Down>", { desc = "Visual select down" })
map({ "n", "v" }, "<S-Left>", "v<Left>", { desc = "Visual select left" })
map({ "n", "v" }, "<S-Right>", "v<Right>", { desc = "Visual select right" })

-- 2. Line Moving (Alt + Up/Down)
-- Uses the exported function from the utils/editor module
map("n", "<A-Down>", function() util_editor.move_line("down") end, { desc = "Move line down (continuous)" })
map("n", "<A-Up>", function() util_editor.move_line("up") end, { desc = "Move line up (continuous)" })

-- Move selection in visual mode (remains as VIM command)
map("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- 3. Clipboard shortcuts (Ctrl + C/X/V)
-- Copy (visual mode)
map("v", "<C-c>", '"+y', { desc = "Copy to system clipboard" })
-- Cut (visual mode)
map("v", "<C-x>", '"+d', { desc = "Cut to system clipboard" })
-- Paste (normal & visual Mode)
map("n", "<C-v>", '"+P', { desc = "Paste from system clipboard" })
map("v", "<C-v>", '"+P', { desc = "Paste from system clipboard" })

-- 4. Select All (Ctrl + A)
-- Select all the contents of a file
map("n", "<C-a>", "ggvG", { desc = "Select all (ggvG)" })

---------------------------------------------------------------------
-- Git integrations
---------------------------------------------------------------------
map("n", "<leader>gg", "<cmd>Neogit<CR>", { desc = "Neogit: open status" })

map("n", "<leader>hs", function()
  local ok, gs = pcall(require, "gitsigns")
  if ok and gs then gs.stage_hunk() else vim.notify("gitsigns not available", vim.log.levels.WARN) end
end, { desc = "Gitsigns: stage hunk" })

map("n", "<leader>hr", function()
  local ok, gs = pcall(require, "gitsigns")
  if ok and gs then gs.reset_hunk() else vim.notify("gitsigns not available", vim.log.levels.WARN) end
end, { desc = "Gitsigns: reset hunk" })

map("n", "<leader>hb", function()
  local ok, gs = pcall(require, "gitsigns")
  if ok and gs then gs.toggle_current_line_blame() else vim.notify("gitsigns not available", vim.log.levels.WARN) end
end, { desc = "Gitsigns: toggle blame" })

---------------------------------------------------------------------
-- Zettelkasten Utility Functions
---------------------------------------------------------------------
local ok_zk, ztk = pcall(require, "utils.zettelkasten")

-- Telekasten commands (These are generic note-taking commands, keep them global)
local ok_tk, telekasten = pcall(require, "telekasten")
if ok_tk and telekasten then
  -- Keymaps for Telekasten commands (no need to restrict by filetype)
  map("n", "<leader>zb", "<cmd>Telekasten show_backlinks<CR>", { desc = "Show Backlinks" })
  map("n", "<leader>zf", "<cmd>Telekasten find_notes<CR>",   { desc = "Find Zettel" })
  map("n", "<leader>zl", "<cmd>Telekasten insert_link<CR>", { desc = "Insert Link" })
  map("n", "<leader>zo", ztk.follow_link_or_open_external, { desc = "Open Link under cursor" })
  map("n", "<leader>zs", "<cmd>Telekasten show_tags<CR>",   { desc = "Show Tags" })
  map("n", "<leader>zt", "<cmd>Telekasten today<CR>",       { desc = "Daily Zettel" })
  
  -- The core creation functions remain global as they can be called anywhere:
  if ok_zk and ztk then
    map("n", "<leader>ze", ztk.open_zotero_create_excerpt, {desc = "Zotero: Create excerpt", buffer = true,})
    map("n", "<leader>zn", ztk.create_new_zettel_with_slug, { desc = "New Zettel with slug" })
  end
end

---------------------------------------------------------------------
-- 🔑 Filetype-Specific Keymaps (Zotero)
---------------------------------------------------------------------

-- Create a single Autocommand Group for all citation keymaps
local citation_augroup = vim.api.nvim_create_augroup("CitationKeymaps", { clear = true })

-- Only load Zotero keymaps for relevant academic filetypes (Markdown, LaTeX, Typst, Telekasten)
if ok_zk and ztk then
  vim.api.nvim_create_autocmd("FileType", {
    group = citation_augroup,
    -- Define the filetypes where Zotero commands should be active
    pattern = { "markdown", "telekasten", "tex", "latex", "typst" },
    callback = function()
      -- The 'buffer = true' option ensures the mapping is local to the current buffer (filetype)
      
      -- Zotero: Insert Citation (dynamic format)
      vim.keymap.set("n", "<leader>zc", ztk.open_zotero_insert_cite, {
        desc = "Zotero: Insert cite key (FT-aware)",
        buffer = true,
      })
    end,
  })
end

---------------------------------------------------------------------
-- Pandoc/LaTeX Build Mappings (Filetype-specific)
---------------------------------------------------------------------
local ok_pdc, pandoc = pcall(require, "utils.pandoc")

if ok_pdc and pandoc then
  vim.api.nvim_create_autocmd("FileType", {
    -- Applies to LaTeX and Markdown/Pandoc files
    pattern = { "tex", "markdown", "pandoc" },
    callback = function(args)
      local bufnr = args.buf
      local ft = vim.bo[bufnr].filetype

      -- Define a local map function for buffer-local keymaps
      local function bufmap(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { 
          noremap = true, 
          silent = true, 
          buffer = bufnr, 
          desc = desc 
        })
      end

      -- === 1. BUILD COMMAND MAPPING: <leader>b ===
      
      if ft == "tex" then
        -- LaTeX Build (multi-step for biblatex: lualatex, biber, lualatex x2)
        bufmap("n", "<leader>b", pandoc.latex_biber_build, "LaTeX: Build to PDF (with Biber)")
      
      elseif ft == "markdown" or ft == "pandoc" then
        -- Markdown/Pandoc Build (single pandoc command)
        bufmap("n", "<leader>b", pandoc.markdown_to_pdf, "Pandoc: Convert to PDF (with Citations)")
      end

      -- === 2. VIEW COMMAND MAPPING: <leader>v ===
      
      -- Common action for all relevant filetypes: View the generated PDF
      bufmap("n", "<leader>v", function()
        local filename = vim.fn.fnamemodify(vim.fn.expand('%'), ':t:r')
        local file_dir = vim.fn.expand('%:p:h')
        vim.cmd('silent !xdg-open ' .. file_dir .. '/' .. filename .. '.pdf &')
      end, "Open generated PDF file")

    end,
  })
end

---------------------------------------------------------------------
-- Pandoc/LaTeX Build Mappings (Filetype-specific)
---------------------------------------------------------------------
local ok_pdc, pandoc = pcall(require, "utils.pandoc")

if ok_pdc and pandoc then
    vim.api.nvim_create_autocmd("FileType", {
        -- Applies to LaTeX and Markdown/Pandoc files
        pattern = { "tex", "markdown", "pandoc" },
        callback = function(args)
            local bufnr = args.buf
            local ft = vim.bo[bufnr].filetype

            -- Define a local map function for buffer-local keymaps
            local function bufmap(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { 
                    noremap = true, 
                    silent = true, 
                    buffer = bufnr, 
                    desc = desc 
                })
            end

            -- === 1. BUILD COMMAND MAPPING: <leader>b ===
            
            if ft == "tex" then
                -- LaTeX Build (multi-step for biblatex: lualatex, biber, lualatex x2)
                bufmap("n", "<leader>b", pandoc.latex_biber_build, "LaTeX: Build to PDF (with Biber)")
            
            elseif ft == "markdown" or ft == "pandoc" then
                -- Markdown/Pandoc Build (single pandoc command)
                bufmap("n", "<leader>b", pandoc.markdown_to_pdf, "Pandoc: Convert to PDF (with Citations)")
            end

            -- === 2. VIEW COMMAND MAPPING: <leader>v ===
            
            -- Common action for all relevant filetypes: View the generated PDF
            bufmap("n", "<leader>v", function()
                local filename = vim.fn.fnamemodify(vim.fn.expand('%'), ':t:r')
                local file_dir = vim.fn.expand('%:p:h')
                vim.cmd('silent !xdg-open ' .. file_dir .. '/' .. filename .. '.pdf &')
            end, "Open generated PDF file")

        end,
    })
end
---------------------------------------------------------------------
-- Completion (cmp centralized)
---------------------------------------------------------------------
local ok_cmp, cmp = pcall(require, "cmp")
if ok_cmp and cmp then
  local ok_luasnip, luasnip = pcall(require, "luasnip")
  if ok_luasnip then require("luasnip.loaders.from_vscode").lazy_load() end

  local select_opts = { behavior = cmp.SelectBehavior.Select }

  cmp.setup({
    snippet = { expand = function(args) if ok_luasnip then luasnip.lsp_expand(args.body) end end },
    mapping = {
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item(select_opts)
        elseif ok_luasnip and luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item(select_opts)
        elseif ok_luasnip and luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    },
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "buffer" },
      { name = "path" },
    }),
  })
end

---------------------------------------------------------------------
-- LSP buffer-local mappings
---------------------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local function bufmap(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, buffer = bufnr, desc = desc })
    end
    
    bufmap("n", "gd", vim.lsp.buf.definition, "LSP: goto def")
    bufmap("n", "K", vim.lsp.buf.hover, "LSP: hover")
    bufmap("n", "gr", vim.lsp.buf.references, "LSP: references")
    bufmap("n", "<leader>rn", vim.lsp.buf.rename, "LSP: rename")
    bufmap("n", "<leader>ca", vim.lsp.buf.code_action, "LSP: code action")
    bufmap("n", "<leader>f", function() vim.lsp.buf.format({ bufnr = bufnr }) end, "LSP: format")
  end,
})
