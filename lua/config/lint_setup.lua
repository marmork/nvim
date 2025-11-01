-- lua/config/lint_setup.lua

local lint = require('lint')

-- Helper function to check if a command exists (optional, but good practice)
local function exists(name)
    local f = io.popen('command -v ' .. name)
    if f then
        local result = f:read('*a')
        f:close()
        return result ~= ''
    end
    return false
end

-- Define linters for filetypes
local linters_by_ft = {}

-- 1. Shellcheck (uses nvim-lint built-in if available, otherwise requires custom setup)
if exists('shellcheck') then
    -- nvim-lint has a built-in 'shellcheck' linter. 
    linters_by_ft.sh = { 'shellcheck' }
end

-- 2. SQLFluff (nvim-lint has a built-in 'sqlfluff' linter)
if exists('sqlfluff') then
    -- If the built-in does not support your custom args (--dialect postgres), 
    -- you might need a custom linter definition (see below for context).
    linters_by_ft.sql = { 'sqlfluff' }
end

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
