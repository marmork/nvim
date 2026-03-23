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
              local path = vim.api.nvim_buf_get_name(0)
              local prompt = "You are a helpful AI assistant."
              
              -- Vollständige Zope-Regeln aus deiner AGENTS.md
              if path:match("WebApp") or path:match("localhost") or path:match("/tmp/") then
                prompt = [[You are an expert for this specific Zope file system mirror system.

This repository is non-standard:
- Code lives in subdirectory __root__
- The directory __root__ is a file system mirror of a Zope ZODB.
- Each directory in __root__ corresponds to an object in the ZODB.
- Each such directory represents an "instance" of a Zope Product.
- The __meta__ file in each directory contains a Python representation of a "meta" dictionary as key-value tuples.
- The "meta" dictionary describes which Zope Product this "instance" instantiates, in the key "type", e.g. "Z SQL Method".
- The "meta" dictionary also contains Properties (for PropertyManager classes) in the key "props".
- The "meta" dictionary also contains the "title" property (class SimpleItem) in the key "title".
- For ObjectManager subclasses (e.g. type "Folder"), the directories may contain subdirectories (contained objects).
- The main contents of the object are placed in a file __source__ with the appropriate extension (e.g. ".py", ".css").
- "Script (Python)" objects contain the function body only, without the "def functionname", and outdented one level.
- "Script (Python)" objects have the function arguments placed in the "args" key of the "meta" dictionary.
- "Script (Python)" objects have namespace bindings in the key "bindings" of the "meta" dictionary.
- "Page Templates" use the TAL and METAL XML namespaces for templating with chameleon

Rules:
- Do not touch the "data" subdirectory, or the "__department_paths__" subdirectory.

When implementing TODOs:
- Prefer extending existing helpers
- Never introduce new dependencies
- Match existing SQL style (lowercase keywords)]]
              end
              
              return string.format("[Active Model: %s]\n\n%s", current_model, prompt)
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
              num_ctx = { default = 32768 },
            },
          })
        end,
      },
    })
    
    notify_model()
  end,
}