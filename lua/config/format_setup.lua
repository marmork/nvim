-- lua/config/format_setup.lua

local conform = require('conform')

-- Helper function to check if a command exists (KEPT for non-Mason tools)
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

-- 1. Black (Now managed by Mason: exists() check removed)
formatters_by_ft.python = { 'black' }

-- 2. Prettier (JS/TS/JSON/Markdown, now managed by Mason: exists() check removed)
formatters_by_ft.javascript = { 'prettier' }
formatters_by_ft.typescript = { 'prettier' }
formatters_by_ft.json = { 'prettier' }
formatters_by_ft.markdown = { 'prettier' }

-- 3. shfmt (Now managed by Mason: exists() check removed)
formatters_by_ft.sh = { 'shfmt' }

-- 4. latexindent (Custom formatter, KEEPING exists() check)
if exists('latexindent') then
    -- 'conform.nvim' supports running external commands directly
    formatters_by_ft.tex = {
        command = 'latexindent',
        args = { '-m', '-l' },
        stdin = true,
    }
    formatters_by_ft.latex = formatters_by_ft.tex
end

-- 5. typstfmt (KEEPING exists() check)
if exists('typstfmt') then
    formatters_by_ft.typst = { 'typstfmt' } -- typstfmt is a built-in conform formatter
end


conform.setup({
    formatters_by_ft = formatters_by_ft,

    -- Enable auto-formatting on save for all configured filetypes
    format_on_save = {
        lsp_fallback = function(bufnr)
            -- Only fallback to LSP if the buffer has an attached LSP client
            local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
            return #clients > 0
        end,
        timeout_ms = 500,
        condition = function(bufnr)
            return vim.bo[bufnr].modifiable and vim.bo[bufnr].filetype ~= ''
        end,
    }
})