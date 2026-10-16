require("nvchad.configs.lspconfig").defaults()

-- lua_ls is already enabled by NvChad
local servers = {
  "pylsp", -- python
  "djlsp", -- django templates
  "clangd", -- c, c++
  "rust_analyzer", -- rust (installed via rustup)
  "ts_ls", -- typescript, javascript
  "html",
  "cssls",
  "vhdl_ls",
}

-- without node (setup.sh --python-only) there is no vscode html server; use superhtml instead
if vim.fn.executable "vscode-html-language-server" == 0 then
  table.insert(servers, "superhtml")
end

vim.lsp.enable(servers)

-- html completion inside django templates too
vim.lsp.config("html", { filetypes = { "html", "templ", "htmldjango" } })

-- read :h vim.lsp.config for changing options of lsp servers, e.g.
-- vim.lsp.config("pylsp", {
--   settings = { pylsp = { plugins = { pycodestyle = { maxLineLength = 120 } } } },
-- })
