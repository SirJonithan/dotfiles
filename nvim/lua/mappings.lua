require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Toggle virtual text with <leader>tv (or any other key combination you prefer)
map('n', '<leader>dv', ":lua require'configs.lspconfig'.toggle_virtual_text()<CR>", opts)

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
