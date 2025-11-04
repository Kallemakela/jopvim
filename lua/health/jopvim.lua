local M = {}

function M.check()
  local health = vim.health or require("health")

  health.start("jopvim")

  local ok, mod = pcall(require, "jopvim")
  if ok then
    health.ok("jopvim module loads")
  else
    health.error("failed to require jopvim: " .. tostring(mod))
    return
  end

  local cmds = vim.api.nvim_get_commands({})
  if cmds["JopCreateCategorizedNote"] then
    health.ok("command JopCreateCategorizedNote available")
  else
    health.error("command JopCreateCategorizedNote missing")
  end
  if cmds["JopOpen"] then
    health.ok("command JopOpen available")
  else
    health.error("command JopOpen missing")
  end

  local deps = {
    "jopvim.config",
    "jopvim.joplinapi",
    "jopvim.note",
    "jopvim.buffer",
    "jopvim.categorize",
    "jopvim.utils",
    "jopvim.http",
  }
  for _, dep in ipairs(deps) do
    local ok_dep = pcall(require, dep)
    if ok_dep then
      health.ok("dependency OK: " .. dep)
    else
      health.error("dependency missing: " .. dep)
    end
  end
end

return M


