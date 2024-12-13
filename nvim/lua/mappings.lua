require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Toggle virtual text with <leader>tv (or any other key combination you prefer)
map('n', '<leader>dv', ":lua require'chadrc'.toggle_virtual_text()<CR>", opts)
-- Keybinding für Autoformatierung mit yapf
map('n', '<leader>df', ':lua vim.lsp.buf.format({ async = true })<CR>', opts)

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
