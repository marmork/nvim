-- lua/config/format_setup.lua

local conform = require('conform')

-- Helper function to check if a command exists (taken from your old config)
local function exists(name)
    local f = io.popen('command -v ' .. name)
    if f then
        local result = f:read('*a')
        f:close()
        return result ~= ''
    end
    return false
end

-- Configuration Table
local formatters_by_ft = {}

-- 1. Black
if exists('black') then
    formatters_by_ft.python = { 'black' }
end

-- 2. Prettier (JS/TS/JSON/Markdown)
if exists('prettier') then
    formatters_by_ft.javascript = { 'prettier' }
    formatters_by_ft.typescript = { 'prettier' }
    formatters_by_ft.json = { 'prettier' }
    formatters_by_ft.markdown = { 'prettier' }
end

-- 3. shfmt
if exists('shfmt') then
    formatters_by_ft.sh = { 'shfmt' }
end

-- 4. latexindent (Custom formatter)
if exists('latexindent') then
    -- 'conform.nvim' supports running external commands directly
    formatters_by_ft.tex = {
        {
            command = 'latexindent',
            args = { '-m', '-l' },
            stdin = true,
        }
    }
    formatters_by_ft.latex = formatters_by_ft.tex
end

-- 5. typstfmt
if exists('typstfmt') then
    formatters_by_ft.typst = { 'typstfmt' } -- typstfmt is a built-in conform formatter
end


conform.setup({
    formatters_by_ft = formatters_by_ft,

    -- Enable auto-formatting on save for all configured filetypes
    format_on_save = {
        -- Use built-in LSPs for formatting if conform has no formatter for the filetype
        lsp_fallback = true,
        -- Default: wait for 500ms for LSPs
        timeout_ms = 500,
        -- Condition to only format if the buffer is modifiable
        condition = function(bufnr)
            return vim.bo[bufnr].modifiable and vim.bo[bufnr].filetype ~= ''
        end,
    },
})

-- The old null-ls autocommand logic is replaced by conform's format_on_save.
-- The only thing left to ensure is that you still need vim.lsp.buf.format
-- for LSPs *if* lsp_fallback is false. Since lsp_fallback is true, 
-- conform handles everything automatically.