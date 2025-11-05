-- Preview Telescope viewer: list with body preview
local previewers = require("telescope.previewers")
local shared = require("jopvim.viewers.viewer_helpers")

local M = {}

-- opts: {
--   prompt_title: string,
--   dynamic_fn: function, -- returns array of entries
--   get_preview_lines: function(entry): table-of-lines
--   layout_strategy/layout_config/preview_width (optional via telescope opts)
--   on_select: function(bufnr)|nil,
--   attach_mappings_ext: function(bufnr)|nil,
--   sorter: any|nil
-- }
function M.open(opts)
  local finder = shared.new_dynamic_finder(opts.dynamic_fn)

  local previewer = previewers.new_buffer_previewer({
    get_buffer_by_name = function(_, entry)
      local id = (entry and entry.value and entry.value.id) or "preview"
      return "jopvim://preview/" .. tostring(id)
    end,
    define_preview = function(self, entry)
      local lines = {}
      if opts.get_preview_lines then
        local ok, result = pcall(opts.get_preview_lines, entry)
        if ok and type(result) == "table" then
          lines = result
        end
      end
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
      vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "markdown")
    end,
  })

  local picker = shared.new_picker({
    prompt_title = opts.prompt_title,
    finder = finder,
    sorter = opts.sorter,
    previewer = previewer,
    on_select = opts.on_select,
    attach_mappings_ext = opts.attach_mappings_ext,
  })

  -- Allow caller to adjust layout on picker after creation via Telescope defaults
  if opts.layout_strategy then picker.layout_strategy = opts.layout_strategy end
  if opts.layout_config then picker.layout_config = opts.layout_config end

  picker:find()
end

return M


