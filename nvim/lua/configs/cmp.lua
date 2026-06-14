local cmp = require("cmp")

-- return {
--   mapping = {
--     ["<M-CR>"] = cmp.mapping(function(fallback)
--       if cmp.visible() then
--         cmp.abort() -- close autocomplete
--       end
--       fallback() -- insert newline
--     end, { "i", "s" }),
--   },
-- }

return {
  mapping = {
    ["<M-CR>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.abort() -- close autocomplete
      end
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<CR>", true, false, true),
        "n",
        true
      )
    end, { "i", "s" }),
  },
}
