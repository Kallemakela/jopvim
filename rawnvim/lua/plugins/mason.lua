return {
  "mason-org/mason.nvim",
  dependencies = { "mason-org/mason-lspconfig.nvim" },
  config = function()
    require("mason").setup()
  end,
}


