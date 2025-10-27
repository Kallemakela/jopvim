-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.mapleader = " "
vim.o.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.o.foldmethod = "indent"
vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.wrap = true
vim.o.swapfile = false
vim.o.winborder = "rounded"
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.g.python3_host_prog = vim.fn.expand("~/mambaforge/bin/python")
