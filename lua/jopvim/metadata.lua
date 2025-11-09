local M = {}

local function current(bufnr)
  if bufnr ~= nil then return bufnr end
  return vim.api.nvim_get_current_buf()
end

function M.get(bufnr)
  bufnr = current(bufnr)
  return vim.b[bufnr].jopvim_meta or {}
end

function M.set(bufnr, meta)
  bufnr = current(bufnr)
  vim.b[bufnr].jopvim_meta = meta or {}
  return vim.b[bufnr].jopvim_meta
end

function M.update(bufnr, patch)
  bufnr = current(bufnr)
  local meta = vim.b[bufnr].jopvim_meta or {}
  for k, v in pairs(patch or {}) do
    meta[k] = v
  end
  vim.b[bufnr].jopvim_meta = meta
  return meta
end

function M.ensure(bufnr, defaults)
  bufnr = current(bufnr)
  local meta = vim.b[bufnr].jopvim_meta or {}
  for k, v in pairs(defaults or {}) do
    if meta[k] == nil then meta[k] = v end
  end
  vim.b[bufnr].jopvim_meta = meta
  return meta
end

return M


