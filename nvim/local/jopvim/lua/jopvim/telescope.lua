-- Telescope live search picker for Joplin notes
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local previewers = require("telescope.previewers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local JoplinAPI = require("jopvim.joplinapi")
local SqlFuzzy = require("jopvim.fuzzy")
local Note = require("jopvim.note")
local Shared = require("jopvim.viewers.viewer_helpers")
local ListViewer = require("jopvim.viewers.list_viewer")
local PreviewViewer = require("jopvim.viewers.preview_viewer")

local M = {}

local format_label = Shared.format_label

function M.search()
  ListViewer.open({
    prompt_title = "Joplin Search",
    dynamic_fn = function(prompt)
      if not prompt or #prompt < 2 then return {} end
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
          display = format_label(n),
        })
      end
      return results
    end,
    sorter = conf.generic_sorter({}),
    on_select = Shared.open_selected,
  })
end

function M.open()
  local page_size = 20
  local state = {
    offset = 0,
    notes = {},
    has_more = true
  }
  
  local function fetch_page()
    local page_num = math.floor(state.offset / page_size) + 1
    local ok, notes = pcall(JoplinAPI.get_notes, {
      limit = page_size,
      page = page_num,
      order_by = "updated_time",
      order_dir = "DESC"
    })
    
    if not ok then
      vim.notify("Failed to fetch notes: " .. tostring(notes), vim.log.levels.ERROR)
      return false
    end
    
    if not notes or #notes == 0 then
      state.has_more = false
      return true
    end
    
    state.notes = notes
    state.has_more = #notes == page_size
    return true
  end
  
  local function create_results()
    local results = {}
    for _, note in ipairs(state.notes) do
      table.insert(results, {
        value = note,
        ordinal = (note.title or note.id or ""),
        display = format_label(note),
      })
    end
    return results
  end
  
  if not fetch_page() then return end
  
  if #state.notes == 0 then
    vim.notify("No notes found", vim.log.levels.INFO)
    return
  end
  
  local function get_prompt_title()
    local page_num = math.floor(state.offset / page_size) + 1
    return string.format("Joplin Notes (Page %d) - <C-n> for next page", page_num)
  end
  
  ListViewer.open({
    prompt_title = get_prompt_title(),
    results = create_results(),
    sorter = conf.generic_sorter({}),
    on_select = Shared.open_selected,
    attach_mappings_ext = function(bufnr)
      local function load_next_page()
        if not state.has_more then
          vim.notify("No more notes to load", vim.log.levels.INFO)
          return
        end
        state.offset = state.offset + page_size
        if not fetch_page() then return end
        local picker = action_state.get_current_picker(bufnr)
        if picker then
          picker:refresh(finders.new_table({
            results = create_results(),
            entry_maker = function(entry)
              return entry
            end,
          }), { reset_prompt = false })
          picker.prompt_title = get_prompt_title()
        end
      end
      vim.keymap.set("n", "<C-n>", load_next_page, { buffer = bufnr, desc = "Load next page" })
    end,
  })
end

function M.fuzzy()
  PreviewViewer.open({
    prompt_title = "Joplin Fuzzy Search",
    dynamic_fn = function(prompt)
      if not prompt or #prompt < 2 then return {} end
      local ok, notes = pcall(SqlFuzzy.fuzzy_candidates, prompt)
      if not ok or type(notes) ~= "table" then return {} end
      local results = {}
      for _, n in ipairs(notes) do
        table.insert(results, {
          value = n,
          ordinal = ((n.title or n.id or "") .. " " .. (n.body or "")),
          display = format_label(n),
        })
      end
      return results
    end,
    sorter = conf.generic_sorter({}),
    layout_strategy = "horizontal",
    layout_config = { width = 0.9, preview_width = 0.55, preview_cutoff = 0 },
    get_preview_lines = function(entry)
      local body = (entry and entry.value and entry.value.body) or ""
      return vim.split(body, "\n", { plain = true })
    end,
    on_select = Shared.open_selected,
  })
end

function M.choose_category(categories, on_choice)
  local results = {}
  for _, c in ipairs(categories) do
    local score = tonumber(c.score) or 0
    local score_str = string.format("%.1f", score * 100)
    table.insert(results, {
      value = c,
      ordinal = (c.title or c.id or ""),
      display = string.format("%s  (%s)", c.title or c.id, score_str),
    })
  end
  
  ListViewer.open({
    prompt_title = "Select Joplin Category",
    results = results,
    sorter = conf.generic_sorter({}),
    on_select = function(bufnr)
      actions.close(bufnr)
      local entry = action_state.get_selected_entry()
      if entry and entry.value then
        on_choice(entry.value)
      end
    end,
  })
end

return M


