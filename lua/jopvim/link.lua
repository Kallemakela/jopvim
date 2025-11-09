-- Link functionality: create and open Joplin note links
local JoplinAPI = require("jopvim.joplinapi")
local Note = require("jopvim.note")

local M = {}

local function format_link(title, note_id)
  return string.format("[%s](:/%s)", title, note_id)
end

local function extract_link_id_from_line(line, col)
  if not line or not col then return nil end
  -- Pattern to match [text](:/id) format
  local pattern = "%[(.-)%]%(%:(/[^%)]+)%)"
  local start = 1
  while true do
    local link_start, link_end, text, id_part = line:find(pattern, start)
    if not link_start then break end
    if col >= link_start and col <= link_end then
      -- Extract just the ID (id_part is /id, we need just id)
      -- Remove leading / if present
      local id = id_part:match("^/(.+)$") or id_part:match("^:/(.+)$") or id_part
      return id, link_start, link_end
    end
    start = link_end + 1
  end
  return nil
end

local function get_current_cursor()
  local cursor = vim.api.nvim_win_get_cursor(0)
  return cursor[1] - 1, cursor[2]  -- Convert to 0-indexed row
end

local function insert_text_at_cursor(text)
  local bufnr = vim.api.nvim_get_current_buf()
  local row, col = get_current_cursor()
  local lines = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)
  local line = lines[1] or ""
  -- col is 0-indexed (cursor position), Lua strings are 1-indexed
  -- If col=0, insert before first char; if col=5, insert before char at position 6
  local before = col == 0 and "" or line:sub(1, col)
  local after = line:sub(col + 1)
  local new_line = before .. text .. after
  vim.api.nvim_buf_set_lines(bufnr, row, row + 1, false, { new_line })
  -- Move cursor after inserted text (row is 0-indexed, need to convert back)
  vim.api.nvim_win_set_cursor(0, { row + 1, col + #text })
end

function M.create_link()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  
  pickers.new({}, {
    prompt_title = "Select Note to Link",
    finder = finders.new_dynamic({
      fn = function(prompt)
        if not prompt or #prompt < 1 then
          local ok, notes = pcall(JoplinAPI.get_notes, {
            limit = 50,
            order_by = "updated_time",
            order_dir = "DESC",
          })
          if not ok or type(notes) ~= "table" then return {} end
          local results = {}
          for _, n in ipairs(notes) do
            table.insert(results, {
              value = n,
              ordinal = (n.title or n.id or ""),
              display = n.title or n.id or "Untitled",
            })
          end
          return results
        end
        local ok, notes = pcall(JoplinAPI.search_notes, {
          query = prompt,
          limit = 50,
          order_by = "updated_time",
          order_dir = "DESC",
        })
        if not ok or type(notes) ~= "table" then return {} end
        local results = {}
        for _, n in ipairs(notes) do
          table.insert(results, {
            value = n,
            ordinal = (n.title or n.id or ""),
            display = n.title or n.id or "Untitled",
          })
        end
        return results
      end,
      entry_maker = function(entry)
        return entry
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(bufnr)
      actions.select_default:replace(function()
        actions.close(bufnr)
        local entry = action_state.get_selected_entry()
        if not entry or not entry.value or not entry.value.id then return end
        local note = entry.value
        local title = note.title or note.id or "Untitled"
        local link_text = format_link(title, note.id)
        insert_text_at_cursor(link_text)
        vim.notify("Created link: " .. title)
      end)
      return true
    end,
  }):find()
end

function M.open_link()
  local bufnr = vim.api.nvim_get_current_buf()
  local row, col = get_current_cursor()
  local lines = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)
  local line = lines[1] or ""
  
  local note_id = extract_link_id_from_line(line, col + 1)
  if not note_id then
    vim.notify("No link found at cursor position", vim.log.levels.WARN)
    return
  end
  
  local ok, note = pcall(JoplinAPI.get_note, note_id)
  if not ok or not note then
    vim.notify("Failed to open note: " .. tostring(note), vim.log.levels.ERROR)
    return
  end
  
  Note.open_note(note)
  vim.notify("Opened note: " .. (note.title or note.id))
end

return M

