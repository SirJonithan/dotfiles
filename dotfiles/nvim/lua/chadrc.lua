-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "onedark",

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

-- A flag to track the virtual text state
local virtual_text_enabled = true

-- Function to toggle virtual text on/off
M.toggle_virtual_text = function()
  virtual_text_enabled = not virtual_text_enabled
  vim.diagnostic.config({
    virtual_text = virtual_text_enabled
    -- You can add other configurations here like signs, underline, etc.
  })

  -- Print message to show the current state of virtual text
  if virtual_text_enabled then
    print("Virtual Text: ON")
  else
    print("Virtual Text: OFF")
  end
end

return M
