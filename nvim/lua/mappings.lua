require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
map("n", "<leader>dv", function()
  local cfg = vim.diagnostic.config()
  local vt = cfg and cfg.virtual_text
  local enabled = (type(vt) == "table") or (vt == true)
  vim.diagnostic.config({ virtual_text = not enabled })
end, { desc = "Toggle virtual text" })
