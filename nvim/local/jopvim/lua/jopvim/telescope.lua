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

local M = {}

local function format_label(note)
  local title = note.title or note.id or "Untitled"
  local updated = note.updated_time and (" (" .. tostring(note.updated_time) .. ")") or ""
  return title .. updated
end

function M.search()
  pickers.new({}, {
    prompt_title = "Joplin Search",
    finder = finders.new_dynamic({
      fn = function(prompt)
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
        local ok, full = pcall(JoplinAPI.get_note, entry.value.id)
        if ok and full then
          Note.open_note(full)
        else
          vim.notify("Failed to load note", vim.log.levels.ERROR)
        end
      end)
      return true
    end,
  }):find()
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
  
  pickers.new({}, {
    prompt_title = get_prompt_title(),
    finder = finders.new_table({
      results = create_results(),
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
        local ok, full = pcall(JoplinAPI.get_note, entry.value.id)
        if ok and full then
          Note.open_note(full)
        else
          vim.notify("Failed to load note", vim.log.levels.ERROR)
        end
      end)
      
      -- Add keymap for loading next page
      local load_next_page = function()
        if not state.has_more then
          vim.notify("No more notes to load", vim.log.levels.INFO)
          return
        end
        
        state.offset = state.offset + page_size
        if not fetch_page() then return end
        
        -- Refresh the picker with new page results
        local picker = action_state.get_current_picker(bufnr)
        if picker then
          picker:refresh(finders.new_table({
            results = create_results(),
            entry_maker = function(entry)
              return entry
            end,
          }), { reset_prompt = false })
          -- Update the prompt title with new page number
          picker.prompt_title = get_prompt_title()
        end
      end
      
      vim.keymap.set("n", "<C-n>", load_next_page, { buffer = bufnr, desc = "Load next page" })
      
      return true
    end,
  }):find()
end

function M.fuzzy()
  pickers.new({}, {
    prompt_title = "Joplin Fuzzy Search",
    layout_strategy = "horizontal",
    layout_config = { width = 0.9, preview_width = 0.55, preview_cutoff = 0 },
    finder = finders.new_dynamic({
      fn = function(prompt)
        if not prompt or #prompt < 2 then return {} end
        local ok, notes = pcall(SqlFuzzy.fuzzy_candidates, prompt)
        if not ok or type(notes) ~= "table" then return {} end
        local results = {}
        for _, n in ipairs(notes) do
          table.insert(results, {
            value = n,
            ordinal = ((n.title or n.id or "") .. " " .. (n.body or "")),
            display = format_label(n),
            -- no preview highlight state retained
          })
        end
        return results
      end,
      entry_maker = function(entry)
        return entry
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      get_buffer_by_name = function(_, entry)
        local id = (entry and entry.value and entry.value.id) or "preview"
        return "jopvim://preview/" .. tostring(id)
      end,
      define_preview = function(self, entry)
        local body = (entry and entry.value and entry.value.body) or ""
        local lines = vim.split(body, "\n", { plain = true })
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "markdown")
      end,
    }),
    attach_mappings = function(bufnr)
      actions.select_default:replace(function()
        actions.close(bufnr)
        local entry = action_state.get_selected_entry()
        if not entry or not entry.value or not entry.value.id then return end
        local ok, full = pcall(JoplinAPI.get_note, entry.value.id)
        if ok and full then
          Note.open_note(full)
        else
          vim.notify("Failed to load note", vim.log.levels.ERROR)
        end
      end)
      return true
    end,
  }):find()
end

return M


