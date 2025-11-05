return {
  "nvim-treesitter/nvim-treesitter",
  build = function()
    -- no-op in headless CI; user can run :TSUpdate manually
  end,
  config = function()
    require('nvim-treesitter.configs').setup({
      ensure_installed = { "python", "lua", "javascript", "typescript" },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}


