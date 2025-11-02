-- ~/.config/nvim/lua/utils/pandoc.lua
-- Utility functions for compiling LaTeX and Markdown to PDF using Pandoc/LaTeX.

local pandoc = {}

-- Fallback function if dispatch is not available
local function fallback_build(cmd)
    vim.notify("vim-dispatch not available. Running command synchronously (blocking).", vim.log.levels.WARN)
    vim.cmd('silent !' .. cmd)
end

-- Function to run the command asynchronously using vim-dispatch
local function run_async(cmd)
    -- ROBUST SOLUTION: We use pcall to safely call vim.cmd(‘Dispatch’).
    -- If Dispatch does not exist (thanks to lazy.nvim), pcall catches the error.
    local success, err = pcall(vim.cmd, 'Dispatch ' .. cmd)
    
    if success then
        vim.notify("Build started in the background: " .. cmd, vim.log.levels.INFO)
    else
        -- Fallback if the dispatch call fails (e.g., because the plugin was not loaded)
        vim.notify("Asynchronous execution failed: " .. tostring(err), vim.log.levels.WARN)
        fallback_build(cmd)
    end
end

--- Compiles a LaTeX file to PDF using lualatex and biber for biblatex support.
-- This requires a multi-step process for full bibliography resolution.
function pandoc.latex_biber_build()   
    local filename = vim.fn.fnamemodify(vim.fn.expand('%'), ':t:r')
    local file_path = vim.fn.expand('%')
    local file_dir = vim.fn.expand('%:p:h')
    
    local commands = {
        'cd ' .. file_dir .. ' && lualatex -shell-escape ' .. filename .. '.tex',
        'cd ' .. file_dir .. ' && biber ' .. filename,
        'cd ' .. file_dir .. ' && lualatex -shell-escape ' .. filename .. '.tex',
        'cd ' .. file_dir .. ' && lualatex -shell-escape ' .. filename .. '.tex',
    }

    -- Chain the commands using '&&' for synchronous execution within a single Dispatch shell
    local chained_cmd = table.concat(commands, ' && ')
    run_async(chained_cmd)
end

--- Converts a Markdown file to PDF using Pandoc, including citation processing.
-- Assumes a 'references.bib' file in the current file or template.
function pandoc.markdown_to_pdf()
    local filename = vim.fn.fnamemodify(vim.fn.expand('%'), ':t:r')
    local file_path = vim.fn.expand('%')
    local file_dir = vim.fn.expand('%:p:h')
    local output_path = file_dir .. '/' .. filename
    
    local pandoc_cmd = string.format(
        'pandoc -s --pdf-engine=lualatex --citeproc -o %s.pdf %s',
        output_path,
        file_path
    )
    run_async(pandoc_cmd)
end

return pandoc