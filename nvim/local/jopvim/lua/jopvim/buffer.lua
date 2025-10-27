-- Buffer-level helpers for creating Joplin notes from the current Neovim buffer
local config = require("jopvim.config").get
local joplinapi = require("jopvim.joplinapi")

local M = {}

local function compute_title(strategy, content)
  if strategy == "filename" then
    return vim.fn.expand("%:t")
  end
  for line in content:gmatch("[^\n]+") do
    local trimmed = line:match("^%s*(.-)%s*$")
    if trimmed ~= "" then return trimmed end
  end
  return "New note"
end

function M.create_from_buffer(category_id, content)
  local cfg = config()
  local title = compute_title(cfg.title_strategy, content)
  local note_data = joplinapi.create_note(category_id, content)
  return joplinapi.update_note(note_data.id, { title = title })
end

function M.create_with_title(category_id, content, title)
  local note_data = joplinapi.create_note(category_id, content)
  return joplinapi.update_note(note_data.id, { title = title })
end

return M
