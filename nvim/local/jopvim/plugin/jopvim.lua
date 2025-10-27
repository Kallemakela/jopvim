if vim.g.loaded_jopvim then return end
vim.g.loaded_jopvim = true

vim.api.nvim_create_user_command("JopCreateCategorizedNote", function()
  require("jopvim").create_categorized_note()
end, { desc = "Create categorized Joplin note via Web Clipper" })

vim.api.nvim_create_user_command("JopCreateUncategorizedNote", function()
  require("jopvim").create_uncategorized_note()
end, { desc = "Create Joplin note in uncategorized folder" })

vim.api.nvim_create_user_command("JopOpen", function()
  require("jopvim").open_notes()
end, { desc = "Open a Joplin note" })

vim.api.nvim_create_user_command("JopSearch", function()
  require("jopvim").search_notes()
end, { desc = "Search and open a Joplin note" })

vim.api.nvim_create_user_command("JopFuzzySearch", function()
  require("jopvim").fuzzy_notes()
end, { desc = "Fuzzy search" })

vim.api.nvim_create_user_command("JopCreateTimeNote", function()
  require("jopvim").create_time_note()
end, { desc = "Create a new time-stamped Joplin note" })
