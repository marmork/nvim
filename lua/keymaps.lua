-- ~/.config/nvim/lua/keymaps.lua

local map = vim.keymap.set

-- File-Browser
map("n", "<leader>n", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle File Tree" })

-- Work spaces
local ws = require("workspaces")
map("n", "<leader>ws", function() ws.switch("writing") end, { desc = "Schreibmodus" })
map("n", "<leader>wc", function() ws.switch("coding") end, { desc = "Codemodus" })
