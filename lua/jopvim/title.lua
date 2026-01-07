local Metadata = require("jopvim.metadata")
local JoplinAPI = require("jopvim.joplinapi")

local M = {}

function M.derive_title(content)
  for line in (content or ""):gmatch("[^\n]+") do
    local trimmed = line:match("^%s*(.-)%s*$")
    if trimmed ~= "" then
      local no_hash = trimmed:gsub("^#+%s*", "")
      if no_hash ~= "" then return no_hash end
      return trimmed
    end
  end
  return "New note"
end

function M.should_update(meta, derived)
  if not derived or derived == "" then return false end
  local current = meta and meta.title or ""
  return derived ~= current
end

function M.finalize(bufnr, new_title)
  local meta = Metadata.ensure(bufnr, {})
  meta.title = new_title
  local id = meta.id or ""
  if id ~= "" then
    local name = string.format("joplin://%s", new_title or "")
    local existing = vim.fn.bufnr(name)
    if existing and existing > 0 and existing ~= bufnr then
      pcall(vim.api.nvim_buf_delete, existing, { force = true })
    end
    vim.api.nvim_buf_set_name(bufnr, name)
  end
  return meta
end

function M.maybe_update_title(bufnr, body)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local meta = Metadata.get(bufnr)
  if not meta or not meta.id or meta.id == "" then return end
  local derived = M.derive_title(body)
  if not M.should_update(meta, derived) then return end
  local ok, res = pcall(JoplinAPI.update_note, meta.id, { title = derived })
  if ok then M.finalize(bufnr, res.title or derived) end
end

return M


