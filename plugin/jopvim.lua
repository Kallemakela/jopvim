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
end, { desc = "Open or search Joplin notes" })

vim.api.nvim_create_user_command("JopFuzzySearch", function()
  require("jopvim").fuzzy_notes()
end, { desc = "Fuzzy search" })

vim.api.nvim_create_user_command("JopCreateTimeNote", function()
  require("jopvim").create_time_note()
end, { desc = "Create a new time-stamped Joplin note" })

vim.api.nvim_create_user_command("JopMeta", function()
  local meta = require("jopvim.metadata").get(0)
  local encoded = (vim.fn and vim.fn.json_encode and vim.fn.json_encode(meta))
    or (vim.inspect and vim.inspect(meta))
    or tostring(meta)
  print(encoded)
end, { desc = "Show current buffer Joplin note metadata" })

vim.api.nvim_create_user_command("JopDelete", function()
  local Note = require("jopvim.note")
  if not Note.is_note(0) then
    vim.notify("Jopvim: current buffer is not a note", vim.log.levels.WARN)
    return
  end
  local meta = require("jopvim.metadata").get(0)
  if not meta.id or meta.id == "" then
    vim.notify("Jopvim: note id missing", vim.log.levels.WARN)
    return
  end
  local ok, err = pcall(require("jopvim.joplinapi").delete_note, meta.id)
  if not ok then
    vim.notify("Jopvim: delete failed - " .. tostring(err), vim.log.levels.ERROR)
    return
  end
  vim.notify("Jopvim: note deleted " .. meta.id)
  pcall(vim.api.nvim_buf_delete, 0, { force = true })
end, { desc = "Delete current Joplin note" })

vim.api.nvim_create_user_command("JopCreateLink", function()
  require("jopvim").create_link()
end, { desc = "Create a link to a Joplin note" })

vim.api.nvim_create_user_command("JopOpenLink", function()
  require("jopvim").open_link()
end, { desc = "Open the Joplin note link at cursor" })
