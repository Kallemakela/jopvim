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
  local checkbox
  if note.is_todo == 1 then
    checkbox = note.todo_completed ~= 0 and "☑ " or "☐ "
  else
    checkbox = ""
  end
  local title = note.title or note.id or "Untitled"
  return checkbox .. title
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

function M.toggle_todo_selected(bufnr)
  local entry = action_state.get_selected_entry()
  if not entry or not entry.value or not entry.value.id then return end
  local ok, updated = pcall(JoplinAPI.toggle_todo, entry.value.id)
  if ok and updated then
    if updated.is_todo ~= 1 then
      vim.notify("Not a todo", vim.log.levels.INFO)
    else
      entry.value.todo_completed = updated.todo_completed or 0
      vim.notify("Todo toggled", vim.log.levels.INFO)
      local picker = action_state.get_current_picker(bufnr)
      if picker and picker.refresh then
        vim.schedule(function()
          pcall(picker.refresh, picker)
        end)
      end
    end
  else
    vim.notify("Failed to toggle todo", vim.log.levels.ERROR)
  end
end

function M.new_picker(opts)
  return pickers.new({}, {
    prompt_title = opts.prompt_title,
    finder = opts.finder,
    sorter = opts.sorter or conf.generic_sorter({}),
    previewer = opts.previewer,
    attach_mappings = function(bufnr, map)
      if opts.on_select then
        actions.select_default:replace(function()
          opts.on_select(bufnr)
        end)
      end
      map("i", "<C-d>", M.toggle_todo_selected)
      map("n", "<C-d>", M.toggle_todo_selected)
      if opts.attach_mappings_ext then
        opts.attach_mappings_ext(bufnr, map)
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

