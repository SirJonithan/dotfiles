require("nvchad.configs.lspconfig").defaults()

-- lua_ls is already enabled by NvChad
local servers = {
  "pylsp", -- python
  "clangd", -- c, c++
  "rust_analyzer", -- rust (installed via rustup)
  "ts_ls", -- typescript, javascript
  "html",
  "cssls",
  "vhdl_ls",
}

vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers, e.g.
-- vim.lsp.config("pylsp", {
--   settings = { pylsp = { plugins = { pycodestyle = { maxLineLength = 120 } } } },
-- })
