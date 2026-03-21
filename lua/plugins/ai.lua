return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",
    "hrsh7th/nvim-cmp",
  },
  keys = {
    -- Toggle the AI chat window
    { "<leader>ca", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI: Toggle Chat" },
    -- Open the Action Palette (Explain, Fix, etc.)
    { "<leader>ce", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI: Actions" },
    -- Add visually selected code to the current chat session
    { "ga", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "AI: Add selection to chat" },
    -- Interactive inline prompt (rewrites code at cursor)
    { "<leader>ci", "<cmd>CodeCompanion<cr>", mode = "n", desc = "AI: Inline Prompt" },

    -- NEW & WORKING MODEL PICKER:
    -- This function opens Telescope with your pre-defined models
    {
      "<leader>cm",
      function()
        local opts = require("telescope.themes").get_dropdown({})
        local models = {
          "qwen2.5-coder:7b",
          "deepseek-coder-v2:16b-lite-instruct-q4_K_M",
          "mistral-nemo",
          "qwen2.5-coder:1.5b",
        }

        require("telescope.pickers").new(opts, {
          prompt_title = "Select AI Model",
          finder = require("telescope.finders").new_table({
            results = models,
          }),
          sorter = require("telescope.config").values.generic_sorter(opts),
          attach_mappings = function(prompt_bufnr, map)
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")

            map("i", "<CR>", function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)

              -- Update the adapter settings globally
              local adapter = require("codecompanion.adapters").resolve("ollama")
              adapter.schema.model.default = selection[1]
              
              vim.notify("Model switched to: " .. selection[1], vim.log.levels.INFO)
            end)
            return true
          end,
        }):find()
      end,
      mode = "n",
      desc = "AI: Select Model (Telescope)",
    },
  },
  config = function()
    require("codecompanion").setup({
      display = {
        action_palette = {
          provider = "telescope",
          opts = {
            show_help_code = true,
          },
        },
        chat = {
          show_settings = true,
          window = {
            layout = "vertical",
            width = 0.4,
          },
        },
      },
      strategies = {
        chat = { adapter = "ollama" },
        inline = { adapter = "ollama" },
        agent = { adapter = "ollama" },
      },
      adapters = {
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            name = "ollama",
            schema = {
              model = {
                default = "qwen2.5-coder:7b",
                choices = {
                  ["Qwen 2.5 Coder 7B (Default)"] = "qwen2.5-coder:7b",
                  ["DeepSeek V2 16B (Logic)"] = "deepseek-coder-v2:16b-lite-instruct-q4_K_M",
                  ["Mistral Nemo 12B (General)"] = "mistral-nemo",
                  ["Qwen 1.5B (Fast)"] = "qwen2.5-coder:1.5b",
                },
              },
              num_ctx = {
                default = 16384,
              },
              num_gpu = { default = 1 },
            },
          })
        end,
      },
    })
  end,
}