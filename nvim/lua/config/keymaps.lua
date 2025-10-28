local map = vim.keymap.set

-- Basic
map({ 'n', 'v', 'x' }, 'J', '}')
map({ 'n', 'v', 'x' }, 'K', '{')
map({ 'n', 'v', 'x' }, '<leader>x', '<cmd>bd<cr>')

-- Search
map('x', 'R', function()
  vim.cmd('normal! "zy')
  local text = vim.fn.getreg('z')
  text = text:gsub('\\', '\\\\'):gsub('\n', '\\n')
  vim.fn.setreg('/', '\\V' .. text)
  vim.o.hlsearch = true
  vim.cmd('normal! n')
end, { silent = true, desc = 'Search visual selection' })
-- Override * to use search
vim.keymap.set({'n' ,'v', 'x'}, '*', function()
  vim.fn.setreg('/', '\\<' .. vim.fn.expand('<cword>') .. '\\>')
  vim.opt.hlsearch = true
end, { silent = true })


-- Terminal mode
map('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })
map('t', '<C-p>', [[<C-\><C-N><C-w>p]], { silent = true })

-- Window
map('n', '<C-p>', '<C-w>p', { silent = true })

-- Clipboard
map({ 'n', 'v', 'x' }, '<leader>y', '"+y<cr>')
map({ 'n', 'v', 'x' }, '<leader>p', '"+d<cr>')

-- LSP overrides
map({"n", "v"}, "gd", vim.lsp.buf.definition, { buffer = bufnr, silent = true })
map({"n", "v"}, "gD", vim.lsp.buf.declaration, { buffer = bufnr, silent = true })
map({"n", "v"}, "gi", vim.lsp.buf.implementation, { buffer = bufnr, silent = true })
map({"n", "v"}, "gt", vim.lsp.buf.type_definition, { buffer = bufnr, silent = true })
map({"n", "v"}, "<C-h>", vim.lsp.buf.hover, { buffer = bufnr, silent = true })

-- Telescope
map('n', '<leader>f', "<cmd>Telescope find_files<cr>")
map('n', '<leader>b', "<cmd>Telescope buffers<cr>")
map('n', '<leader>op', "<cmd>Telescope commands<cr>")

-- Runner
map("n", "<leader>lc", "<cmd>CodeRun<cr>", { desc = "Run", silent = true })
map("n", "<leader>lt", "<cmd>CodeToggle<cr>", { desc = "Toggle runner term", silent = true })
map("n", "<leader>ls", "<cmd>CodeRunLast<cr>", { desc = "Run last", silent = true })
map("n", "<leader>lo", "<cmd>OpenLinks<cr>", { desc = "Open from runner", silent = true })

-- Jopvim
map("n", "<leader>jo", "<cmd>JopOpen<cr>", { desc = "Joplin Open", silent = true })
map("n", "<leader>jt", "<cmd>JopCreateTimeNote<cr>", { desc = "Joplin Create time note", silent = true })
map("n", "<leader>js", "<cmd>JopSearch<cr>", { desc = "Joplin Search", silent = true })
map("n", "<leader>jc", "<cmd>JopCreateCategorizedNote<cr>", { desc = "Categorize joplin note", silent = true })
map("n", "<leader>jf", "<cmd>JopFuzzySearch<cr>", { silent = true, desc = "Joplin: Fuzzy Search" })
map(
  "n",
  "<leader>ja",
  "<cmd>JopCreateUncategorizedNote<cr>",
  { silent = true, desc = "Joplin: Create uncategorized note" }
)

-- Vim-test
map("n", "<leader>tn", ":TestNearest<CR>", { silent = true })
map("n", "<leader>tf", ":TestFile<CR>",    { silent = true })
map("n", "<leader>ta", ":TestSuite<CR>",   { silent = true })
map("n", "<leader>tl", ":TestLast<CR>",    { silent = true })
map("n", "<leader>td", ":DebugLastTest<CR>", { silent = true, desc = "Debug last test" })

-- Configs
map("n", "<leader>cr", "<cmd>ReloadConfig<cr>", { desc = "Reload config", silent = true })
