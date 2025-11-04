-- SQLite access (path resolution for Joplin desktop DB); future queries TBD
local config = require("jopvim.config").get

local M = {}

local function expand_path(p)
  if type(p) ~= "string" or p == "" then return p end
  if p:sub(1, 2) == "~/" then
    local home = vim.fn.expand("~")
    return home .. p:sub(2)
  end
  return p
end

function M.get_path()
  local cfg = config()
  return expand_path(cfg.sqlite_path)
end

function M.run(sql, params)
  local db = M.get_path()
  if not db or db == "" then error("sqlite path not configured") end
  local args = { "sqlite3", "-json", db, sql }
  local job = vim.system(args, { text = true, stdin = nil })
  local res = job:wait()
  if res.code ~= 0 then
    error("sqlite3 failed: " .. (res.stderr or tostring(res.code)))
  end
  local out = res.stdout or "[]"
  local ok, decoded = pcall(vim.fn.json_decode, out)
  if not ok or type(decoded) ~= "table" then return {} end
  return decoded
end

return M


