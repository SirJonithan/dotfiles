return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim" },
    },
    cmd = {
      "CopilotChatOpen",
      "CopilotChatToggle",
    },
    keys = {
      { "<leader>cc", "<cmd>CopilotChatToggle<CR>", mode = "n", desc = "Toggle Copilot Chat" },
      { "<leader>cc", "<cmd>CopilotChatOpen<CR>", mode = "v", desc = "Copilot Chat (selection)" },
    },
    opts = {
      model = "gpt-4.1",
      show_help = false,
    },
  },
}
