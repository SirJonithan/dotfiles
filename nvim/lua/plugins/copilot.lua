return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    },
    cmd = {
      "CopilotChatOpen",
      "CopilotChatToggle",
    },
    opts = {
      -- model = "gpt-5",
      -- show_help = false,
    },
    config = function(_, opts)
      require("CopilotChat").setup(opts)

      local map = vim.keymap.set

      -- Toggle chat
      map("n", "<leader>cc", "<cmd>CopilotChatToggle<CR>", { desc = "Toggle Copilot Chat" })
      map("v", "<leader>cc", "<cmd>CopilotChatOpen<CR>", { desc = "Copilot Chat (selection)" })
    end,
  },
}

