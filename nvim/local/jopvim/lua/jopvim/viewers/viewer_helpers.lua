-- Telescope viewer helpers
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local JoplinAPI = require("jopvim.joplinapi")
local Note = require("jopvim.note")

local M = {}

function M.format_label(note)
  local title = note.title or note.id or "Untitled"
  local updated = note.updated_time and (" (" .. tostring(note.updated_time) .. ")") or ""
  return title .. updated
end

function M.make_entry(note)
  return {
    value = note,
    ordinal = (note.title or note.id or ""),
    display = M.format_label(note),
  }
end

function M.open_selected(bufnr)
  actions.close(bufnr)
  local entry = action_state.get_selected_entry()
  if not entry or not entry.value or not entry.value.id then return end
  local ok, full = pcall(JoplinAPI.get_note, entry.value.id)
  if ok and full then
    Note.open_note(full)
  else
    vim.notify("Failed to load note", vim.log.levels.ERROR)
  end
end

function M.new_picker(opts)
  return pickers.new({}, {
    prompt_title = opts.prompt_title,
    finder = opts.finder,
    sorter = opts.sorter or conf.generic_sorter({}),
    previewer = opts.previewer,
    attach_mappings = function(bufnr)
      if opts.on_select then
        actions.select_default:replace(function()
          opts.on_select(bufnr)
        end)
      end
      if opts.attach_mappings_ext then
        opts.attach_mappings_ext(bufnr)
      end
      return true
    end,
  })
end

function M.new_table_finder(results)
  return finders.new_table({
    results = results,
    entry_maker = function(entry)
      return entry
    end,
  })
end

function M.new_dynamic_finder(fn)
  return finders.new_dynamic({
    fn = fn,
    entry_maker = function(entry)
      return entry
    end,
  })
end

return M

