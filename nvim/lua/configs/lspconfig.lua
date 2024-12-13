-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

-- EXAMPLE
local servers = { "html", "cssls", "pylsp", "eslint"}
local nvlsp = require "nvchad.configs.lspconfig"

vim.diagnostic.config({
    virtual_text = true,    -- Disable virtual text
    signs = true,           -- Keep signs in the gutter
    update_in_insert = false, -- Disable diagnostics while typing
    underline = false,      -- Underline errors in the code
    severity_sort = true,   -- Sort diagnostics by severity
})

-- LSPs with default config for non-Python servers
for _, lsp in ipairs(servers) do
    if lsp == "pylsp" then
        -- Custom configuration for pylsp to enable flake8
        lspconfig.pylsp.setup {
            on_attach = nvlsp.on_attach,
            on_init = nvlsp.on_init,
            capabilities = nvlsp.capabilities,
            settings = {
                pylsp = {
                    configurationSources = { "flake8" },  -- Use flake8 for linting config
                    plugins = {
                        pyflakes = { enabled = false },  -- Disable pycodestyle
                        pycodestyle = { enabled = false },  -- Disable pycodestyle
                        mccabe = { enabled = false },  -- Disable pycodestyle
                        flake8 = { enabled = true },        -- Enable flake8
                    },
                },
            },
        }
    else
        -- Default setup for other servers
        lspconfig[lsp].setup {
            on_attach = nvlsp.on_attach,
            on_init = nvlsp.on_init,
            capabilities = nvlsp.capabilities,
            settings = {
                eslint = {
                    workingDirrectory = {mode = "global"},
                },
            },
        }
    end
end

lspconfig.html.setup {
    on_attach = function(client, bufnr)
        local opts = { noremap = true, silent = true }
    end,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    filetypes = { "html", "htmldjango" } -- Enable for both HTML and Django HTML
}
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
