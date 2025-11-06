-- Plugin configuration: defaults, setup(opts), and resolved getter
local M = {}

local default_config = {
  categorizer_url = "http://localhost:13131/category",
  joplin_url = "http://localhost:41184",
  joplin_token = "",
  title_strategy = "first_non_empty_line", -- or "filename"
  sqlite_path = "~/.config/joplin-desktop/database.sqlite",
  fuzzy_min_chars = 2,
  fuzzy_max_rows = 100000,
  uncategorized_folder_id = "556eb0171cd047b68777bf6a01bdd129",
  time_note_folder_id = "63f7a0b57a9b471bb1e5757b5603ee0a",
}

local user_config = {}

function M.setup(opts)
  user_config = opts or {}
end

function M.get()
  local cfg = {}
  for k, v in pairs(default_config) do
    cfg[k] = v
  end
  for k, v in pairs(user_config) do
    cfg[k] = v
  end
  if not cfg.joplin_token or cfg.joplin_token == "" then
    cfg.joplin_token = vim.env.JOPLIN_TOKEN or ""
  end
  return cfg
end

return M


