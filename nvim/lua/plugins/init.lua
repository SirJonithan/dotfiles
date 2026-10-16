return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, require "configs.cmp")
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "vimdoc", "lua", "luadoc", "printf",
        "bash", "json", "toml", "yaml", "markdown", "markdown_inline",
        "python", "htmldjango",
        "c", "cpp", "cmake", "make",
        "rust",
        "javascript", "typescript", "tsx", "html", "css",
        "vhdl",
      },
      -- install parsers synchronously when run headless (setup.sh), async otherwise
      sync_install = #vim.api.nvim_list_uis() == 0,
    },
  },
}
