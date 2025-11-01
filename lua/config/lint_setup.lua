-- lua/config/lint_setup.lua
-- Configuration for nvim-lint. Tools are managed by mason.nvim.

local lint = require('lint')

-- The 'exists' function and associated checks are REMOVED 
-- because Mason handles the installation and pathing for 'shellcheck' and 'sqlfluff'.

-- Define linters for filetypes
local linters_by_ft = {}

-- 1. Shellcheck (Now guaranteed by Mason)
linters_by_ft.sh = { 'shellcheck' }

-- 2. SQLFluff (Now guaranteed by Mason)
-- Note: If you have custom arguments (e.g., --dialect postgres) that the built-in
-- linter does not support, you may need a custom linter definition here.
linters_by_ft.sql = { 'sqlfluff' }

-- Apply the configured linters to nvim-lint
lint.linters_by_ft = linters_by_ft

-- Autocommand to run the linters automatically after a file is saved
vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
    callback = function()
        -- Only run the linter if the buffer is active and not an internal buffer (like help)
        if vim.api.nvim_get_current_win() ~= 0 then
            require('lint').try_lint()
        end
    end,
})