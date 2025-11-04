-- Public plugin API: setup, create note flows, open/search notes
local Config = require("jopvim.config")
local Categorize = require("jopvim.categorize")
local Buffer = require("jopvim.buffer")
local Note = require("jopvim.note")
local JoplinAPI = require("jopvim.joplinapi")
local Telescope = require("jopvim.telescope")
local Link = require("jopvim.link")

local M = {}

function M.setup(opts)
  Config.setup(opts or {})
end

function M.create_categorized_note()
  local categories = Categorize.get_sorted_categories()
  local bufnr = vim.api.nvim_get_current_buf()
  local content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
  Telescope.choose_category(categories, function(c)
    local ok, res = pcall(Buffer.create_from_buffer, c.id, content)
    if not ok then
      vim.notify("Joplin: " .. res, vim.log.levels.ERROR)
      return
    end
    Note.open_note_in_current_buffer(res)
    vim.notify("Joplin note created: " .. (res.id or ""))
  end)
end

function M.create_uncategorized_note()
  local folder_id = Config.get().uncategorized_folder_id
  local ok, res = pcall(Buffer.create_with_title, folder_id, "", "New note")
  if not ok then
    vim.notify("Joplin: " .. tostring(res), vim.log.levels.ERROR)
    return
  end
  Note.open_note(res)
  vim.notify("Created uncategorized note")
end

function M.open_notes()
  require("jopvim.telescope").open()
end

function M.search_notes()
  require("jopvim.telescope").search()
end

function M.fuzzy_notes()
  require("jopvim.telescope").fuzzy()
end

function M.create_time_note()
  local folder_id = Config.get().time_note_folder_id
  local title = os.date("%Y%m%d %H:%M:%S")
  local ok, res = pcall(Buffer.create_with_title, folder_id, "", title)
  if not ok then
    vim.notify("Joplin: " .. tostring(res), vim.log.levels.ERROR)
    return
  end
  Note.open_note(res)
  vim.notify("Created time note: " .. title)
end

function M.create_link()
  Link.create_link()
end

function M.open_link()
  Link.open_link()
end

return M


