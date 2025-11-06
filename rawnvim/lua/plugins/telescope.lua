return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require('telescope').setup({
      defaults = {
        file_ignore_patterns = {
          "node_modules",
          "%.git/",
          "build/",
          "dist/",
          "__pycache__/",
          "logs/",
          "%.egg%-info/",
          "%.lock",
        },
        mappings = {
          i = {
            ["<C-j>"] = require("telescope.actions").move_selection_next,
            ["<C-k>"] = require("telescope.actions").move_selection_previous,
            ["<C-l>"] = require("telescope.actions").select_default,
          },
        },
      },
      pickers = {
        find_files = {
          no_ignore = true,
        },
      },
    })
  end,
}


