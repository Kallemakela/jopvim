-- Shared helpers for consistency across modules
local M = {}

function M.decode_json(s)
  local ok, res = pcall(vim.json.decode, s)
  if ok then return res end
  return vim.fn.json_decode(s)
end

function M.encode_json(t)
  local ok, res = pcall(vim.json.encode, t)
  if ok then return res end
  return vim.fn.json_encode(t)
end

return M
