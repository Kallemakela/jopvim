local runner = require("coderunner.runner")
local links = require("coderunner.links")
local picker = require("coderunner.picker")
local config = require("coderunner.config")

local M = {}

function M.setup(opts)
  config.setup(opts or {})
end

function M.run_current_file()
  runner.run_current_file()
end

function M.toggle_terminal()
  runner.toggle_terminal()
end

function M.open_links()
  local lines = runner.get_runner_lines()
  local urls = links.collect_from_lines(lines)
  if #urls == 0 then
    print("No file links found in Runner")
    return
  end
  table.sort(urls, function(a, b)
    local sa, sb = links.score_path(a.path), links.score_path(b.path)
    if sa ~= sb then return sa < sb end
    if a.path ~= b.path then return a.path < b.path end
    return (a.line or 0) < (b.line or 0)
  end)
  picker.pick_and_open(urls, links.score_path)
end

function M.run_last_command()
  runner.run_last_command()
end

return M


