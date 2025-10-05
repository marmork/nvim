-- ~/.config/nvim/lua/keymaps.lua
-- central keymaps

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- file tree toggle
map("n", "<leader>n", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle File Tree" })

-- workspaces
local ws_ok, ws = pcall(require, "workspaces")
if ws_ok and ws then
  map("n", "<leader>ws", function() ws.switch("writing") end, { desc = "Schreibmodus" })
  map("n", "<leader>wc", function() ws.switch("coding") end,  { desc = "Codemodus" })
else
  -- fallback: notify if module missing
  map("n", "<leader>ws", function() vim.notify("workspace module missing", vim.log.levels.WARN) end, opts)
  map("n", "<leader>wc", function() vim.notify("workspace module missing", vim.log.levels.WARN) end, opts)
end

-- zettelkasten keymaps (use utils/zettelkasten functions; safe require)
local ok_zk, ztk = pcall(require, "utils.zettelkasten")
if ok_zk and ztk then
  map("n", "<leader>zn", ztk.create_new_zettel_with_slug, { desc = "New Zettel with slug" })
  map("n", "<leader>zb", "<cmd>Telekasten show_backlinks<CR>", { desc = "Show Backlinks" })
  map("n", "<leader>zf", "<cmd>Telekasten find_notes<CR>", { desc = "Find Zettel" })
  map("n", "<leader>zl", "<cmd>Telekasten insert_link<CR>", { desc = "Insert Link" })
  map("n", "<leader>zo", "<cmd>Telekasten follow_link<CR>", { desc = "Open Link under cursor" })
  map("n", "<leader>zs", "<cmd>Telekasten show_tags<CR>", { desc = "Show Tags" })
  map("n", "<leader>zt", "<cmd>Telekasten today<CR>", { desc = "Daily Zettel" })
  map("n", "<leader>zc", ztk.open_zotero_insert_cite, { desc = "Zotero: insert cite key" })
  map("n", "<leader>ze", ztk.open_zotero_create_excerpt, { desc = "Zotero: create excerpt" })
else
  -- graceful fallback if utils missing
  map("n", "<leader>zn", function() vim.notify("zettelkasten utils missing", vim.log.levels.WARN) end, opts)
end
