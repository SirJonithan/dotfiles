require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Toggle virtual text with <leader>tv (or any other key combination you prefer)
map('n', '<leader>dv', function()
    local current_config = vim.diagnostic.config()
    local new_virtual_text = not current_config.virtual_text
    vim.diagnostic.config({
      virtual_text = new_virtual_text
    })end,
  {desc = "Toggle virtual Text"}

)
map("i", "<C-i>", function()
  vim.lsp.buf.signature_help()
end, { noremap = true, silent = true })
