-- merged into NvChad's nvim-cmp options (see plugins/init.lua)
local cmp = require "cmp"

return {
  mapping = {
    -- close the completion menu and insert a newline
    ["<M-CR>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.abort()
      end
      vim.api.nvim_feedkeys(vim.keycode "<CR>", "n", true)
    end, { "i", "s" }),
  },
}
