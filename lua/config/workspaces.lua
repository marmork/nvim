-- ~/.config/nvim/lua/workspaces.lua
-- Writing / Coding workspace switching

local M = {}

-- Load local paths
local paths = require("config.local_paths")

M.coding_path  = vim.fn.expand(paths.coding_path)
M.writing_path = vim.fn.expand(paths.writing_path)

function M.switch(mode)
  local path
  if mode == "writing" then
    path = M.writing_path
  elseif mode == "coding" then
    path = M.coding_path
  else
    vim.notify("Unknown workspace: " .. tostring(mode), vim.log.levels.WARN)
    return
  end

  -- ensure NvimTree uses the correct path
  vim.cmd("NvimTreeClose")
  vim.cmd("cd " .. path)
  vim.cmd("NvimTreeOpen " .. path)
  vim.notify("Switched to: " .. path, vim.log.levels.INFO)
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
