local M = {}

local defaults = {
  save_before_runner = true,
}

local opts = vim.deepcopy(defaults)

function M.setup(user_opts)
  if type(user_opts) == "table" then
    for k, v in pairs(user_opts) do
      opts[k] = v
    end
  end
end

function M.get(key)
  return opts[key]
end

function M.maybe_save_current_buffer(reason)
  if not opts.save_before_runner then return end
  if reason then
    print("[coderunner] save_before_runner -> " .. tostring(reason))
  else
    print("[coderunner] save_before_runner")
  end
  vim.cmd("silent write")
end

return M


