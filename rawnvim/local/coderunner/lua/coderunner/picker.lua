local M = {}

function M.pick_and_open(urls, score_path)
  local ok_pickers, pickers = pcall(require, "telescope.pickers")
  local ok_finders, finders = pcall(require, "telescope.finders")
  local ok_conf, conf = pcall(require, "telescope.config")
  local ok_actions, actions = pcall(require, "telescope.actions")
  local ok_state, action_state = pcall(require, "telescope.actions.state")

  if not (ok_pickers and ok_finders and ok_conf and ok_actions and ok_state) then
    print("Telescope not available")
    return
  end

  pickers.new({}, {
    prompt_title = "Runner File Links",
    finder = finders.new_table({
      results = urls,
      entry_maker = function(item)
        local display = item.path .. ":" .. tostring(item.line)
        return {
          value = item,
          display = display,
          ordinal = string.format("%03d %s", score_path(item.path), display),
        }
      end,
    }),
    sorter = conf.values.generic_sorter({}),
    attach_mappings = function(_, map)
      local function open_selected()
        local entry = action_state.get_selected_entry()
        if not entry or not entry.value then return end
        local p = entry.value.path
        local l = entry.value.line or 1
        if p and p ~= '' then
          vim.cmd(string.format("edit +%d %s", l, vim.fn.fnameescape(p)))
        end
      end
      map({ "i", "n" }, "<CR>", function(prompt_bufnr)
        actions.close(prompt_bufnr)
        open_selected()
      end)
      return true
    end,
  }):find()
end

return M


