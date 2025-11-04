-- Minimal HTTP client using curl via vim.system for JSON APIs
local M = {}

local function build_curl_args(method, url, headers, body)
  local args = { "-sS", "--fail-with-body", "-X", method, url }
  if headers then
    for name, value in pairs(headers) do
      table.insert(args, "-H")
      table.insert(args, name .. ": " .. value)
    end
  end
  if body then
    table.insert(args, "--data-binary")
    table.insert(args, body)
  end
  return args
end

function M.request(method, url, headers, body)
  local args = build_curl_args(method, url, headers, body)
  local result = vim.system({ "curl", unpack(args) }, { text = true }):wait()
  local status = result.code or 0
  local stdout = result.stdout or ""
  local stderr = result.stderr or ""
  return status, stdout, stderr
end

return M


