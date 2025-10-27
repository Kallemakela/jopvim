vim.pack.add({
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/Mofiqul/vscode.nvim' },
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
    { src = 'https://github.com/nvim-telescope/telescope.nvim' },
    { src = 'https://github.com/stevearc/oil.nvim' },
    { src = 'https://github.com/mason-org/mason.nvim' },
    { src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
    { src = 'https://github.com/tpope/vim-fugitive' },
    { src = 'https://github.com/vim-test/vim-test' },
    { src = 'https://github.com/numToStr/Comment.nvim' },
    -- { src = 'https://github.com/ray-x/lsp_signature.nvim' },
    { src = 'https://github.com/mfussenegger/nvim-dap' },
    { src = 'https://github.com/rmagatti/auto-session' }, -- TODO replace, this e.g. does not preserve window types, breakpoints etc.
})

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
    },
    pickers = {
        find_files = {
            no_ignore = true,
            -- no_ignore = false,
        },
    },
})
require('oil').setup({})
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "pyright", "ts_ls", "jsonls", "bashls" },
})
require('nvim-treesitter.configs').setup({
    ensure_installed = { "python", "lua", "javascript", "typescript" },
    highlight = { enable = true },
    indent = { enable = true },
})
require('Comment').setup()
-- require('lsp_signature').setup()
require("auto-session").setup({})


vim.cmd("colorscheme vscode")

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.commands")

-- Local plugins
vim.cmd.packadd('jopvim')
vim.cmd.packadd('coderunner')

-- Configs for ext plugins
require("config.vimtest")
require("config.dap")
