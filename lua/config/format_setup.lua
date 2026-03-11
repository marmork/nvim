--- @file format_setup.lua
--- @brief Configuration for conform.nvim (Formatter)
---
--- This setup handles:
--- 1. Global trailing whitespace trimming for all filetypes.
--- 2. Python formatting via Ruff.
--- 3. JS/TS specifically forced to 4-space tabs; others (JSON/MD) use defaults.
--- 4. Shell script and LaTeX/Typst formatting.
--- 5. Automatic format-on-save with LSP fallback.

local conform = require('conform')

-- Helper function to check if a command exists (for non-Mason tools)
local function exists(name)
    local f = io.popen('command -v ' .. name)
    if f then
        local result = f:read('*a')
        f:close()
        return result ~= ''
    end
    return false
end

-- 1. Custom Formatter for 4-space JS/TS
-- We create a specialized version of prettier just for these filetypes
local prettier_4_spaces = { "prettier", args = { "--stdin-filepath", "$FILENAME", "--tab-width", "4" } }

-- 2. Define Formatter mappings by Filetype
local formatters_by_ft = {
    -- The "*" filetype runs formatters on ALL files.
    ["*"] = { "trim_whitespace" },
    -- Python
    python = { "ruff_format" },

    -- JS/TS: Use the 4-space override
    javascript = { prettier_4_spaces },
    typescript = { prettier_4_spaces },

    json = { "prettier" },
    markdown = { "prettier" },

    -- Shell
    sh = { "shfmt" },
}

-- 3. Add Conditional Formatters (Non-Mason)
if exists('latexindent') then
    formatters_by_ft.tex = {
        command = 'latexindent',
        args = { '-m', '-l' },
        stdin = true,
    }
    formatters_by_ft.latex = formatters_by_ft.tex
end

if exists('typstfmt') then
    formatters_by_ft.typst = { 'typstfmt' }
end

-- 4. Final Setup
conform.setup({
    formatters_by_ft = formatters_by_ft,

    format_on_save = {
        -- Only fallback to LSP if no conform formatter is found for the filetype
        lsp_fallback = true, 
        timeout_ms = 500,
        condition = function(bufnr)
            -- Only format if the buffer is modifiable
            return vim.bo[bufnr].modifiable and vim.bo[bufnr].filetype ~= ''
        end,
    }
})