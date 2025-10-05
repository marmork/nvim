-- ~/.config/nvim/lua/workspaces.lua
-- Functions for switching between workspaces

local M = {}

local writing_path = vim.fn.expand("~/Dokumente/Schreiben")
local coding_path = vim.fn.expand("~/repos")

function M.switch(mode)
  local path
  if mode == "writing" then
    path = writing_path
  elseif mode == "coding" then
    path = coding_path
  else
    print("❌ Unbekannter Modus: " .. tostring(mode))
    return
  end

  vim.cmd("NvimTreeClose")
  vim.cmd("cd " .. path)
  vim.cmd("NvimTreeOpen " .. path)
  print("Wechsel zu: " .. path)
end

-- Open automatically when starting (optional)
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      local ok, _ = pcall(require, "nvim-tree")
      if ok then
        vim.cmd("NvimTreeOpen " .. writing_path)
      end
    end
  end,
  once = true,
})

return M
