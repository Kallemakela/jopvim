-- Note buffer UX: open note in a normal buffer and handle saving back to Joplin
local JoplinAPI = require("jopvim.joplinapi")
local Meta = require("jopvim.metadata")
local Title = require("jopvim.title")

local M = {}

local function clear_existing(name)
  local existing = vim.fn.bufnr(name)
  if existing and existing > 0 then
    pcall(vim.api.nvim_buf_delete, existing, { force = true })
  end
end

local function attach_write_handler(bufnr, note_id)
  vim.bo[bufnr].buftype = "acwrite"
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].modifiable = true
  vim.bo[bufnr].readonly = false
  vim.api.nvim_buf_set_var(bufnr, "joplin_note_id", note_id)
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = bufnr,
    callback = function(args)
      local id = vim.b[args.buf].joplin_note_id
      if not id or id == "" then return end
      local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
      local body = table.concat(lines, "\n")
      local ok, res = pcall(JoplinAPI.update_note, id, { body = body })
      if not ok then
        vim.notify("Joplin save failed: " .. tostring(res), vim.log.levels.ERROR)
        return
      end
      vim.bo[args.buf].modified = false
      vim.notify("Joplin note saved: " .. (res.id or id))
      Title.maybe_update_title(args.buf, body)
    end,
  })
end

local function ensure_lines(lines)
  if not lines or #lines == 0 then return { "" } end
  return lines
end

local function create_and_show_note_buffer(id, title, body)
  local lines = ensure_lines(vim.split(body or "", "\n", { plain = true }))
  local bufnr = vim.api.nvim_create_buf(true, false)
  local old_undolevels = vim.bo[bufnr].undolevels
  vim.bo[bufnr].undolevels = -1
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_win_set_buf(0, bufnr)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  vim.bo[bufnr].filetype = "markdown"
  vim.bo[bufnr].modifiable = true
  vim.bo[bufnr].readonly = false
  vim.bo[bufnr].buftype = "acwrite"
  vim.bo[bufnr].bufhidden = "hide"
  local name = string.format("joplin://%s %s", id or "", title or "Untitled")
  clear_existing(name)
  vim.api.nvim_buf_set_name(bufnr, name)
  vim.bo[bufnr].undolevels = old_undolevels
  vim.bo[bufnr].modified = false
  Meta.set(bufnr, { id = id, title = title })
  return bufnr
end

local function populate_current_buffer(id, title, body)
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = ensure_lines(vim.split(body or "", "\n", { plain = true }))
  local old_undolevels = vim.bo[bufnr].undolevels
  vim.bo[bufnr].undolevels = -1
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  vim.bo[bufnr].filetype = "markdown"
  vim.bo[bufnr].modifiable = true
  vim.bo[bufnr].readonly = false
  vim.bo[bufnr].buftype = "acwrite"
  vim.bo[bufnr].bufhidden = "hide"
  local name = string.format("joplin://%s %s", id or "", title or "Untitled")
  clear_existing(name)
  vim.api.nvim_buf_set_name(bufnr, name)
  vim.bo[bufnr].undolevels = old_undolevels
  vim.bo[bufnr].modified = false
  Meta.set(bufnr, { id = id, title = title })
  return bufnr
end

function M.open_note(note)
  local title = note.title or "Untitled"
  local id = note.id or ""
  local body = note.body or ""
  local bufnr = create_and_show_note_buffer(id, title, body)
  attach_write_handler(bufnr, id)
  vim.bo[bufnr].modified = false
end

function M.open_note_in_current_buffer(note)
  local title = note.title or "Untitled"
  local id = note.id or ""
  local body = note.body or ""
  local bufnr = populate_current_buffer(id, title, body)
  attach_write_handler(bufnr, id)
  vim.bo[bufnr].modified = false
end

function M.update_note_inplace(id_or_note, new_body)
  local id = type(id_or_note) == "table" and id_or_note.id or id_or_note
  local updated = JoplinAPI.update_note(id, { body = new_body })
  M.open_note(updated)
  return updated
end

function M.refresh_note_inplace(id)
  local note = JoplinAPI.get_note(id)
  M.open_note(note)
  return note
end

function M.is_note(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(bufnr)
  if type(name) == "string" and name:match("^joplin://") then return true end
  local meta = Meta.get(bufnr)
  if meta and (meta.id or meta.title) then return true end
  return false
end

return M


