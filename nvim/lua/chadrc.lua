-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "onedark",

  -- hl_override = {
  --   Comment = { italic = true },
  --   ["@comment"] = { italic = true },
  -- },
}

-- M.nvdash = { load_on_startup = true }

-- :MasonInstallAll installs every enabled LSP server and conform formatter (+ pkgs)
M.mason = {
  -- mason names NvChad can't derive (or derives wrongly) from the configs
  pkgs = { "rust_hdl", "vsg" },
  -- rust-analyzer comes from rustup so it always matches the toolchain;
  -- rust-hdl is NvChad's outdated name for rust_hdl
  skip = { "rust-analyzer", "rust-hdl" },
}

return M
