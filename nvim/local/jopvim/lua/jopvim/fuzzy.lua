-- SQLite-backed fuzzy over Joplin notes (title + body) with tokenized LIKE
local cfg_get = require("jopvim.config").get
local sqlite = require("jopvim.sqliteapi")

local M = {}

local function split_tokens(s)
  local tokens = {}
  for t in string.gmatch(s or "", "[^%s]+") do
    table.insert(tokens, t)
  end
  return tokens
end

function M.fuzzy_candidates(prompt)
  local cfg = cfg_get()
  if not prompt or #prompt < (cfg.fuzzy_min_chars or 2) then return {} end
  local sql = string.format(
    "SELECT id, title, body, updated_time FROM notes ORDER BY updated_time DESC LIMIT %d",
    tonumber(cfg.fuzzy_max_rows or 10000) or 10000
  )
  local rows = sqlite.run(sql)
  return rows
end

return M


