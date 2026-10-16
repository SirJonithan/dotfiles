local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_format" },
    htmldjango = { "djlint" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    rust = { "rustfmt" },
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    css = { "prettier" },
    html = { "prettier" },
    vhdl = { "vsg" },
  },

  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

return options
