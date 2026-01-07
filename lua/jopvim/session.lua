local M = {}

local function extract_note_id(bufnr)
	local name = vim.api.nvim_buf_get_name(bufnr)
	return name:match(" | Joplin %[(%w+)%]$")
end

function M.restore_buffer(bufnr)
	local id = extract_note_id(bufnr)
	if not id then
		return
	end
	local JoplinAPI = require("jopvim.joplinapi")
	local Note = require("jopvim.note")
	local ok, note = pcall(JoplinAPI.get_note, id)
	if not ok then
		return
	end

	pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
	Note.open_note(note)
end

function M.setup()
	vim.api.nvim_create_autocmd("SessionLoadPost", {
		callback = function()
			vim.defer_fn(function()
				local buffers = vim.api.nvim_list_bufs()
				for _, bufnr in ipairs(buffers) do
					local name = vim.api.nvim_buf_get_name(bufnr)
					if name:match(" | Joplin %[") then
						M.restore_buffer(bufnr)
					end
				end
			end, 100)
		end,
	})
end

return M
