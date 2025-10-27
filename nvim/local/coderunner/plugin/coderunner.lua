if vim.g.loaded_coderunner then return end
vim.g.loaded_coderunner = true

vim.api.nvim_create_user_command("CodeRun", function()
  require("coderunner").run_current_file()
end, { desc = "Run the current file in a terminal" })

vim.api.nvim_create_user_command("CodeToggle", function()
  require("coderunner").toggle_terminal()
end, { desc = "Toggle the runner terminal" })

vim.api.nvim_create_user_command("OpenLinks", function()
  require("coderunner").open_links()
end, { desc = "List and open links from Runner via Telescope" })

vim.api.nvim_create_user_command("CodeRunLast", function()
  require("coderunner").run_last_command()
end, { desc = "Run the last command in Runner terminal" })
