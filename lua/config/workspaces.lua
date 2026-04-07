-- ~/.config/nvim/lua/workspaces.lua
-- Writing / Coding workspace switching

local M = {}

-- Load local paths
local paths = require("config.local_paths")
M.coding_path  = vim.fn.expand(paths.coding_path)
M.writing_path = vim.fn.expand(paths.writing_path)

function M.switch(mode)
  local path = (mode == "writing") and M.writing_path or M.coding_path
  if not path then
    vim.notify("Unknown workspace: " .. tostring(mode), vim.log.levels.WARN)
    return
  end

  vim.api.nvim_set_current_dir(path)

  local ok, api = pcall(require, "nvim-tree.api")
  if ok then
    api.tree.change_root(path)
    if not api.tree.is_visible() then
      api.tree.open()
    end
  end
  
  vim.notify("Workspace: " .. mode:upper() .. " -> " .. path, vim.log.levels.INFO)
end

-- Optional: open writing workspace on VimEnter if no files given (keeps previous behaviour)
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      local ok, _ = pcall(require, "nvim-tree")
      if ok then
        vim.cmd("NvimTreeOpen " .. M.writing_path)
      end
    end
  end,
  once = true,
})

return M
