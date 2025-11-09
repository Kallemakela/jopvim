-- List-only Telescope viewer built on shared helpers
local shared = require("jopvim.viewers.viewer_helpers")

local M = {}

-- opts: {
--   prompt_title: string,
--   results: table|nil, -- array of entries
--   dynamic_fn: function|nil, -- returns array of entries
--   on_select: function(bufnr)|nil,
--   attach_mappings_ext: function(bufnr)|nil,
--   sorter: any|nil
-- }
function M.open(opts)
  local finder
  if opts.dynamic_fn then
    finder = shared.new_dynamic_finder(opts.dynamic_fn)
  else
    finder = shared.new_table_finder(opts.results or {})
  end

  local picker = shared.new_picker({
    prompt_title = opts.prompt_title,
    finder = finder,
    sorter = opts.sorter,
    on_select = opts.on_select,
    attach_mappings_ext = opts.attach_mappings_ext,
  })

  picker:find()
end

return M


