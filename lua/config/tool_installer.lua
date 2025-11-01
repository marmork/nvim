-- lua/config/tool_installer.lua
-- Ensures all required formatters (for conform.nvim) and linters (for nvim-lint) are installed via Mason.

require('mason-tool-installer').setup({
    -- List of tools that Mason will ensure are installed locally.
    ensure_installed = {
        -- Formatters (used by conform.nvim)
        'black',        -- Python formatter
        'prettier',     -- JS/TS/JSON/Markdown formatter
        'shfmt',        -- Shell script formatter
        'sqlfluff',     -- SQL formatter

        -- Linters (used by nvim-lint)
        'shellcheck',   -- Shell script linter

        -- Note: If you need linters for Python (e.g., 'ruff'), 
        -- or if 'sqlfluff' can be used as a linter, add them here.
    },
})
