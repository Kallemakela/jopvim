-- Joplin Web Clipper API bindings (notes CRUD, listing, and search)
local config = require("jopvim.config").get
local http = require("jopvim.http")
local utils = require("jopvim.utils")

local M = {}

local function url_encode(str)
  if not str or str == "" then return "" end
  return (str:gsub("[^%w._~-]", function(c)
    return string.format("%%%02X", string.byte(c))
  end))
end

function M.create_note(category_id, content)
  local cfg = config()
  if not cfg.joplin_token or cfg.joplin_token == "" then
    error("Joplin token missing. Set JOPLIN_TOKEN env or jopvim.setup({ joplin_token = ... }).")
  end
  local url = string.format("%s/notes?token=%s", cfg.joplin_url, url_encode(cfg.joplin_token))
  local body = utils.encode_json({ body = content, parent_id = category_id })
  local headers = { ["Content-Type"] = "application/json" }
  local status, resp_body, err = http.request("POST", url, headers, body)
  if status ~= 0 then
    error("Joplin note creation failed: " .. (err or resp_body or tostring(status)))
  end
  local data = utils.decode_json(resp_body)
  if not data or not data.id then
    error("Unexpected Joplin response")
  end
  return data
end

function M.get_note(id)
  local cfg = config()
  local base = string.format("%s/notes/%s?token=%s", cfg.joplin_url, id, url_encode(cfg.joplin_token or ""))
  -- request body explicitly to ensure content is returned
  local url = base .. "&fields=" .. url_encode("id,title,body,parent_id,updated_time,created_time,is_todo,todo_due,todo_completed")
  local status, resp_body, err = http.request("GET", url, { ["Accept"] = "application/json" }, nil)
  if status ~= 0 then
    error("Joplin get_note failed: " .. (err or resp_body or tostring(status)))
  end
  local data = utils.decode_json(resp_body)
  if not data or not data.id then error("Unexpected Joplin response") end
  return data
end

function M.update_note(id, fields)
  local cfg = config()
  local url = string.format("%s/notes/%s?token=%s", cfg.joplin_url, id, url_encode(cfg.joplin_token or ""))
  local body = utils.encode_json(fields or {})
  local status, resp_body, err = http.request("PUT", url, { ["Content-Type"] = "application/json" }, body)
  if status ~= 0 then
    error("Joplin update_note failed: " .. (err or resp_body or tostring(status)))
  end
  local data = utils.decode_json(resp_body)
  if not data or not data.id then error("Unexpected Joplin response") end
  return data
end

local function build_query_params(opts, extra_fields)
  local params = {}
  if opts and opts.query then table.insert(params, "query=" .. url_encode(opts.query)) end
  if extra_fields then
    for _, field in ipairs(extra_fields) do
      table.insert(params, field)
    end
  end
  if opts and opts.limit then table.insert(params, "limit=" .. tostring(opts.limit)) end
  if opts and opts.page then table.insert(params, "page=" .. tostring(opts.page)) end
  if opts and opts.order_by then table.insert(params, "order_by=" .. url_encode(opts.order_by)) end
  if opts and opts.order_dir then table.insert(params, "order_dir=" .. url_encode(opts.order_dir)) end
  table.insert(params, "fields=" .. url_encode("id,title,body,updated_time,is_todo,todo_due,todo_completed"))
  return params
end

local function fetch_notes(endpoint, opts, extra_fields)
  local cfg = config()
  if opts and opts.query == "" then return {} end
  local params = build_query_params(opts, extra_fields)
  local url = string.format("%s%s?token=%s&%s", cfg.joplin_url, endpoint, url_encode(cfg.joplin_token or ""), table.concat(params, "&"))
  local status, body, err = http.request("GET", url, { ["Accept"] = "application/json" }, nil)
  if status ~= 0 then
    error("Joplin request failed: " .. (err or body or tostring(status)))
  end
  local data = utils.decode_json(body)
  if type(data) ~= "table" then error("Unexpected Joplin response") end
  local items = data.items or data
  if type(items) ~= "table" then error("Unexpected Joplin response: missing items") end
  return items
end

function M.get_notes(options)
  return fetch_notes("/notes", options)
end

function M.search_notes(opts)
  return fetch_notes("/search", opts, { "type=note" })
end

function M.delete_note(id)
  local cfg = config()
  local url = string.format("%s/notes/%s?token=%s", cfg.joplin_url, id, url_encode(cfg.joplin_token or ""))
  local status, resp_body, err = http.request("DELETE", url, { ["Accept"] = "application/json" }, nil)
  if status ~= 0 then
    error("Joplin delete_note failed: " .. (err or resp_body or tostring(status)))
  end
  return true
end

function M.toggle_todo(id)
  local note = M.get_note(id)
  if not note or note.is_todo ~= 1 then
    return note
  end
  local new_completed = note.todo_completed == 0 and os.time() or 0
  return M.update_note(id, { todo_completed = new_completed })
end

return M
