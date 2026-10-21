require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

map("n", "<leader>dv", function()
  vim.diagnostic.config { virtual_text = not vim.diagnostic.config().virtual_text }
end, { desc = "Toggle diagnostic virtual text" })

map("i", "<C-i>", vim.lsp.buf.signature_help, { desc = "LSP signature help" })

map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP code action" })
