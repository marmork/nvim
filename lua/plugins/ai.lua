return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "hrsh7th/nvim-cmp", -- For autocomplete integration
  },
  -- Define keymaps here (Lazy-loading style)
  keys = {
    -- Toggle Chat (Normal & Visual)
    { "<leader>ca", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI: Toggle Chat" },
    -- Inline Actions / Menu (Normal & Visual)
    { "<leader>ce", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI: Actions" },
    -- Add selection to chat (Visual only)
    { "ga", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "AI: Add selection to chat" },
    -- Inline prompt/rewrite (Normal only)
    { "<leader>ci", "<cmd>CodeCompanion<cr>", mode = "n", desc = "AI: Inline Prompt" },
  },
  config = function()
    require("codecompanion").setup({
      strategies = {
        -- Configuration for different AI interaction methods
        chat = {
          adapter = "ollama",
        },
        inline = {
          adapter = "ollama",
        },
        agent = {
          adapter = "ollama",
        },
      },
      adapters = {
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            name = "qwen-coder",
            schema = {
              model = {
                default = "qwen2.5-coder:7b", -- Verify version with 'ollama list'
              },
              num_ctx = {
                default = 16384, -- Large context for complex files
              },
            },
          })
        end,
      },
    })
  end,
}