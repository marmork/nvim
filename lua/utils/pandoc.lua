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
    if disp_ok then
        -- The ":Dispatch" command runs the command in the background
        vim.cmd('Dispatch ' .. cmd)
        vim.notify("Build started in the background: " .. cmd, vim.log.levels.INFO)
    else
        fallback_build(cmd)
    end
end

--- Compiles a LaTeX file to PDF using lualatex and biber for biblatex support.
-- This requires a multi-step process for full bibliography resolution.
function pandoc.latex_biber_build()
    vim.cmd('write') -- Always save before starting the build
    
    local filename = vim.fn.fnamemodify(vim.fn.expand('%'), ':t:r')
    local file_path = vim.fn.expand('%')
    
    local commands = {
        'lualatex -shell-escape ' .. file_path,
        'biber ' .. filename,
        'lualatex -shell-escape ' .. file_path,
        'lualatex -shell-escape ' .. file_path, -- Final run for TOC/references
    }

    -- Chain the commands using '&&' for synchronous execution within a single Dispatch shell
    local chained_cmd = table.concat(commands, ' && ')

    run_async(chained_cmd)
end

--- Converts a Markdown file to PDF using Pandoc, including citation processing.
-- Assumes a 'references.bib' file in the current directory or a specified path.
function pandoc.markdown_to_pdf()
    vim.cmd('write') -- Always save before starting the conversion

    local filename = vim.fn.fnamemodify(vim.fn.expand('%'), ':t:r')
    local file_path = vim.fn.expand('%')
    local bib_file = 'references.bib' -- Customize the default bibliography file name
    
    local pandoc_cmd = string.format(
        'pandoc -s --pdf-engine=lualatex --citeproc --bibliography=%s -o %s.pdf %s',
        bib_file,
        filename,
        file_path
    )

    run_async(pandoc_cmd)
end

return pandoc