return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",
    "hrsh7th/nvim-cmp",
  },
  keys = {
    { "<leader>ca", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI: Toggle Chat" },
    { "<leader>ce", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI: Actions" },
    { "ga", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "AI: Add selection to chat" },
    { "<leader>ci", "<cmd>CodeCompanion<cr>", mode = "n", desc = "AI: Inline Prompt" },

    {
      "<leader>cm",
      function()
        local opts = require("telescope.themes").get_dropdown({})
        local models = {
          "qwen3.5:9b",
          "qwen3-coder-next",
          "deepseek-r1:8b",
          "qwen2.5-coder:7b",
        }

        require("telescope.pickers").new(opts, {
          prompt_title = "Select AI Model (Next Gen)",
          finder = require("telescope.finders").new_table({ results = models }),
          sorter = require("telescope.config").values.generic_sorter(opts),
          attach_mappings = function(prompt_bufnr, map)
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")

            map("i", "<CR>", function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)

              local adapter = require("codecompanion.adapters").resolve("ollama")
              adapter.schema.model.default = selection[1]
              
              vim.notify("Modell gewechselt zu: " .. selection[1], vim.log.levels.INFO)
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
        action_palette = { provider = "telescope", opts = { show_help_code = true } },
        chat = { 
          show_settings = true, 
          window = { layout = "vertical", width = 0.4 } 
        },
      },
      strategies = {
        chat = {
          adapter = "ollama",
        },
        inline = { adapter = "ollama" },
        agent = { adapter = "ollama" },
      },
      adapters = {
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            name = "ollama",
            schema = {
              model = {
                default = "qwen3.5:9b",
                choices = {
                  ["Qwen 3.5 (9B)"] = "qwen3.5:9b",
                  ["Qwen 3 Coder Next (MoE)"] = "qwen3-coder-next",
                  ["DeepSeek R1 (8B)"] = "deepseek-r1:8b",
                  ["Qwen 2.5 Coder (7B)"] = "qwen2.5-coder:7b",
                },
              },
              num_ctx = { default = 32768 },
              num_gpu = { default = 1 },
            },
          })
        end,
      },
    })
  end,
}