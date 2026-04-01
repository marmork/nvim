-- ~/.config/nvim/lua/plugins/ai.lua

local model_file = vim.fn.stdpath("data") .. "/codecompanion_model"

local function load_model()
  local f = io.open(model_file, "r")
  if f then
    local m = f:read("*l")
    f:close()
    if m and m ~= "" then return m end
  end
  return "qwen3.5:9b"
end

local function save_model(model)
  local f = io.open(model_file, "w")
  if f then
    f:write(model)
    f:close()
  end
end

local current_model = load_model()
local models = {
  "qwen3.5:9b",
  "qwen3-coder-next",
  "deepseek-r1:8b",
  "qwen2.5-coder:7b",
}

local function notify_model()
  vim.notify("󱚣 Active AI: " .. current_model, vim.log.levels.INFO, { title = "CodeCompanion" })
end

-- Helper to read AGENTS.md from the project root
local function get_agents_prompt()
  local root = vim.fs.dirname(vim.fs.find({ "AGENTS.md", ".git" }, { upward = true })[1])
  if root then
    local agents_file = root .. "/AGENTS.md"
    local f = io.open(agents_file, "r")
    if f then
      local content = f:read("*a")
      f:close()
      return content
    end
  end
  return nil
end

return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",
    "hrsh7th/nvim-cmp",
  },

  keys = {
    { "<leader>ca", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "Toggle Chat" },
    { "<leader>ce", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI Actions" },
    { "ga", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Add to Chat" },
    { "<leader>cv", function() notify_model() end, mode = "n", desc = "Check AI Model" },
    
    {
      "<leader>cm",
      function()
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")

        require("telescope.pickers").new(require("telescope.themes").get_dropdown({}), {
          prompt_title = "Select AI Model",
          finder = require("telescope.finders").new_table({ results = models }),
          sorter = require("telescope.config").values.generic_sorter({}),
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              
              current_model = selection[1]
              save_model(current_model)
              notify_model()
              
              -- Hinweis: Bestehende Chats behalten oft ihr Modell. 
              -- Für das neue Modell einfach einen neuen Chat öffnen.
            end)
            return true
          end,
        }):find()
      end,
      mode = "n",
      desc = "Select Model",
    },
  },

  config = function()
    require("codecompanion").setup({
      strategies = {
        chat = {
          adapter = "ollama",
          opts = {
            system_prompt = function()
              local agents_rules = get_agents_prompt()
              
              if agents_rules then
                -- Use the instructions directly from your repo's AGENTS.md
                return string.format(
                  "[Active Model: %s]\n\n%s",
                  current_model,
                  agents_rules
                )
              else
                -- Fallback for non-Zope projects
                return "You are a helpful AI assistant."
              end
            end,
          },
        },
        inline = { adapter = "ollama" },
      },
      adapters = {
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            name = "ollama",
            schema = {
              model = {
                default = function()
                  return current_model
                end,
              },
              num_ctx = { default = 24576 },
            },
          })
        end,
      },
    })
    
    notify_model()
  end,
}