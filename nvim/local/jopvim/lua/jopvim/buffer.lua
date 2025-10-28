-- Buffer-level helpers for creating Joplin notes from the current Neovim buffer
local joplinapi = require("jopvim.joplinapi")
local Title = require("jopvim.title")

local M = {}

function M.create_from_buffer(category_id, content)
  local title = Title.derive_title(content)
  local note_data = joplinapi.create_note(category_id, content)
  return joplinapi.update_note(note_data.id, { title = title })
end

function M.create_with_title(category_id, content, title)
  local note_data = joplinapi.create_note(category_id, content)
  return joplinapi.update_note(note_data.id, { title = title })
end

return M
