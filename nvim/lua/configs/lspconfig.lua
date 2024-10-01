-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

-- EXAMPLE
local servers = { "html", "cssls", "pylsp"}
local nvlsp = require "nvchad.configs.lspconfig"

vim.diagnostic.config({
    virtual_text = false,  -- Disable virtual text
    signs = true,          -- Keep signs in the gutter
    update_in_insert = false,  -- Disable diagnostics while typing
    underline = false,      -- Underline errors in the code
    severity_sort = true,  -- Sort diagnostics by severity
})

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

-- -- Configure pylsp
-- lspconfig.pylsp.setup {
--     on_attach = function(client, bufnr)
--         -- Add additional configurations here if needed
--     end,
--     settings = {
--         pylsp = {
--             plugins = {
--                 pylint = { enabled = true }, -- Enable pylint
--                 pyflakes = { enabled = false }, -- Disable pyflakes (optional)
--                 flake8 = { enabled = false }, -- Disable flake8 (optional)
--                 yapf = { enabled = true }, -- Enable yapf for formatting
--             },
--         },
--     },
-- }

-- configuring single server, example: typescript
-- lspconfig.tsserver.setup {
--   on_attach = nvlsp.on_attach,
--   on_init = nvlsp.on_init,
--   capabilities = nvlsp.capabilities,
-- }
