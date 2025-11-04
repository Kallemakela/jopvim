-- Calls external categorizer API to rank categories for the current buffer content
local config = require("jopvim.config").get
local http = require("jopvim.http")
local utils = require("jopvim.utils")

local M = {}

local function get_buffer_content()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  return table.concat(lines, "\n")
end

local function write_temp_file(content)
  local tmp = vim.fn.tempname()
  vim.fn.writefile(vim.split(content, "\n"), tmp)
  return tmp
end


local function sort_by_score(items)
  table.sort(items, function(a, b)
    local sa = tonumber(a.score) or 0
    local sb = tonumber(b.score) or 0
    return sa > sb
  end)
  return items
end

function M.get_sorted_categories()
  local cfg = config()
  local content = get_buffer_content()
  local tmpfile = write_temp_file(content)
  local payload = utils.encode_json({ sequence = content })
  local status, body, err = http.request(
    "POST",
    cfg.categorizer_url,
    { ["Content-Type"] = "application/json" },
    payload
  )
  if status ~= 0 then
    error("Categorizer request failed: " .. (err or body or tostring(status)))
  end
  local data = utils.decode_json(body)
  if type(data) ~= "table" then
    error("Invalid categorizer response")
  end
  return sort_by_score(data)
end

return M


