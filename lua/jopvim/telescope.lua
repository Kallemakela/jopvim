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
  PreviewViewer.open({
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
      if not entry or not entry.value or not entry.value.id then return {} end
      local note = entry.value
      if note.body then
        return vim.split(note.body, "\n", { plain = true })
      end
      local ok, full = pcall(JoplinAPI.get_note, note.id)
      if ok and full and full.body then
        note.body = full.body
        return vim.split(full.body, "\n", { plain = true })
      end
      return {}
    end,
    on_select = Shared.open_selected,
  })
end

function M.open()
  local state = {
    page = 1,
    current_prompt = ""
  }

  local function get_prompt_title()
    if state.current_prompt ~= "" then
      return string.format("Joplin Search: %s (Page %d) - <C-p> prev <C-n> next", state.current_prompt, state.page)
    else
      return string.format("Joplin Notes (Page %d) - <C-p> prev <C-n> next", state.page)
    end
  end

  PreviewViewer.open({
    prompt_title = get_prompt_title(),
    dynamic_fn = function(prompt)
      if prompt ~= state.current_prompt then
        state.page = 1
        state.current_prompt = prompt
      end

      local ok, notes
      if prompt ~= "" then
        ok, notes = pcall(JoplinAPI.search_notes, {
          query = prompt,
          limit = 50,
          page = state.page,
          order_by = "updated_time",
          order_dir = "DESC",
        })
      else
        ok, notes = pcall(JoplinAPI.get_notes, {
          limit = 40,
          page = state.page,
          order_by = "updated_time",
          order_dir = "DESC"
        })
      end

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
      if not entry or not entry.value or not entry.value.id then return {} end
      local note = entry.value
      if note.body then
        return vim.split(note.body, "\n", { plain = true })
      end
      local ok, full = pcall(JoplinAPI.get_note, note.id)
      if ok and full and full.body then
        note.body = full.body
        return vim.split(full.body, "\n", { plain = true })
      end
      return {}
    end,
    on_select = Shared.open_selected,
    attach_mappings_ext = function(bufnr, map)
      local function load_next_page()
        state.page = state.page + 1
        local picker = action_state.get_current_picker(bufnr)
        if picker then
          picker:refresh()
          picker.prompt_title = get_prompt_title()
        end
      end

      local function load_prev_page()
        state.page = math.max(1, state.page - 1)
        local picker = action_state.get_current_picker(bufnr)
        if picker then
          picker:refresh()
          picker.prompt_title = get_prompt_title()
        end
      end

      map("n", "<C-n>", load_next_page)
      map("i", "<C-n>", load_next_page)
      map("n", "<C-p>", load_prev_page)
      map("i", "<C-p>", load_prev_page)
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


