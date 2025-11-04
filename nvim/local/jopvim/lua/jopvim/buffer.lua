-- Buffer-level helpers for creating Joplin notes from the current Neovim buffer
local joplinapi = require("jopvim.joplinapi")
local Title = require("jopvim.title")

local M = {}

local function compose_body_with_title(title, content)
  local body = "# " .. (title or "")
  if content and content ~= "" then
    body = body .. "\n\n" .. content
  end
  return body
end

function M.create_from_buffer(category_id, content)
  local title = Title.derive_title(content)
  local note_data = joplinapi.create_note(category_id, content)
  return joplinapi.update_note(note_data.id, { title = title })
end

function M.create_with_title(category_id, content, title)
  local body = compose_body_with_title(title, content or "")
  local note_data = joplinapi.create_note(category_id, body)
  return joplinapi.update_note(note_data.id, { title = title })
end

return M
