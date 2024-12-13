require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "pylsp", "djlsp" }
vim.lsp.enable(servers)

vim.lsp.config("pylsp", {
  settings = {
    pylsp = {
      plugins = {
        isort = { enabled = true },
      },
    },
  },
})

-- read :h vim.lsp.config for changing options of lsp servers 
