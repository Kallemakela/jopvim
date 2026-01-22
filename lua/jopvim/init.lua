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
  require("jopvim.session").setup()
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
  M.create_note_from_content("", Config.get().uncategorized_folder_id)
end

function M.open_notes()
  require("jopvim.telescope").open()
end

function M.fuzzy_notes()
  require("jopvim.telescope").fuzzy()
end

function M.create_time_note()
  local folder_id = Config.get().time_note_folder_id
  local title = os.date("%Y%m%d %H:%M:%S")
  M.create_note_from_content(title, folder_id)
end

function M.create_link()
  Link.create_link()
end

function M.open_link()
  Link.open_link()
end

function M.create_note_from_content(content, folder_id)
  folder_id = folder_id or Config.get().uncategorized_folder_id
  local body = content or ""
  body = "# " .. body
  local ok, res = pcall(Buffer.create_from_buffer, folder_id, body)
  if not ok then
    vim.notify("Joplin: " .. tostring(res), vim.log.levels.ERROR)
    return
  end
  Note.open_note(res)
  vim.notify("Joplin note created: " .. (res.id or ""))
  return res
end

function M.get_range_content(opts)
  if not opts.line1 or not opts.line2 then
    return nil
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local start_line = opts.line1 - 1
  local end_line = opts.line2
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)
  return table.concat(lines, "\n")
end

function M.jopnote_command(opts)
  local content = ""
  local folder_id = nil
  if opts.line1 and opts.line2 then
    content = M.get_range_content(opts) or ""
    if opts.args and opts.args ~= "" then
      folder_id = M.parse_folder_id_from_args(opts.args)
    end
  elseif opts.args and opts.args ~= "" then
    local parsed = M.parse_content_and_folder_id(opts.args)
    content = parsed.content
    folder_id = parsed.folder_id
  end
  M.create_note_from_content(content, folder_id)
end

function M.parse_folder_id_from_args(args)
  local folder_id_match = args:match("folder_id=([%w]+)")
  if folder_id_match then
    return folder_id_match
  end
  local folder_id_match2 = args:match("--folder%-id=([%w]+)")
  if folder_id_match2 then
    return folder_id_match2
  end
  return nil
end

function M.parse_content_and_folder_id(args)
  local folder_id = M.parse_folder_id_from_args(args)
  local content = args
  if folder_id then
    content = content:gsub("folder_id=[%w]+%s*", "")
    content = content:gsub("--folder%-id=[%w]+%s*", "")
    content = content:match("^%s*(.-)%s*$")
  else
    local first_word = args:match("^([%w]+)")
    if first_word and #first_word == 32 and first_word:match("^[%da-fA-F]+$") then
      folder_id = first_word
      content = args:sub(#first_word + 1):match("^%s*(.-)%s*$")
    end
  end
  return { content = content or "", folder_id = folder_id }
end

return M


