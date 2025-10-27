local M = {}

local function normalize_path(p)
  if not p or p == '' then return p end
  if p:sub(1, 2) == "~/" then p = vim.fn.expand(p) end
  local function exists(x)
    if x == '' then return false end
    if vim.fn.filereadable(x) == 1 then return true end
    local st = (vim.loop and vim.loop.fs_stat) and vim.loop.fs_stat(x) or nil
    return st ~= nil
  end
  if exists(p) then return p end
  local collapsed = p
  collapsed = collapsed:gsub("%s*/%s*", "/")
  collapsed = collapsed:gsub("([^/])%s+([^/])", "%1%2")
  if exists(collapsed) then return collapsed end
  return collapsed
end

local function try_match(s)
  local p, n = string.match(s, 'File%s+"([^"]+)",%s*line%s+(%d+)')
  if not p then p, n = string.match(s, "File%s+'([^']+)',%s*line%s+(%d+)") end
  if not p then p, n = string.match(s, "([^%s:]+):(%d+)") end
  return p, n
end

function M.collect_from_lines(lines)
  local seen, links = {}, {}
  for i = #lines, 1, -1 do
	-- This could be heavily optimized if needed
    local candidates = {
      lines[i],
      (lines[i] or "") .. " " .. (lines[i+1] or ""),
      (lines[i-1] or "") .. " " .. (lines[i] or ""),
      (lines[i] or "") .. " " .. (lines[i+1] or "") .. " " .. (lines[i+2] or ""),
      (lines[i-2] or "") .. " " .. (lines[i-1] or "") .. " " .. (lines[i] or ""),
    }
    for _, s in ipairs(candidates) do
      local path, lnum = try_match(s)
      if path and lnum then
        path = normalize_path(path)
        local key = path .. ":" .. lnum
        if not seen[key] then
          table.insert(links, { path = path, line = tonumber(lnum) })
          seen[key] = true
        end
        break
      end
    end
  end
  return links
end

function M.score_path(p)
  if not p or p == '' then return 1000 end
  if p:sub(1,1) == '<' then return 200 end
  local s = 0
  if p:find('/site%-packages/', 1, true) then s = s + 80 end
  if p:find('/lib/python', 1, true) then s = s + 70 end
  if p:find('/mambaforge/', 1, true) or p:find('/conda/', 1, true) then s = s + 60 end
  local cwd = vim.loop and vim.loop.cwd and vim.loop.cwd() or vim.fn.getcwd()
  if cwd and p:find(cwd, 1, true) == 1 then s = s - 20 end
  if p:find('/code/', 1, true) then s = s - 10 end
  return s
end

return M


