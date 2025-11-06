local M = {}
local config = require("coderunner.config")

local term_buf, term_win

function M.find_runner_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local name = vim.api.nvim_buf_get_name(buf)
      if name:match("Runner$") then
        if vim.bo[buf].buftype == "terminal" then
          return buf
        else
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end
    end
  end
end

function M.find_runner_win()
  local buf = M.find_runner_buf()
  if buf then
    local wins = vim.fn.win_findbuf(buf)
    if #wins > 0 then
      return wins[1]
    end
  end
end

function M.ensure_runner_window()
  local win = M.find_runner_win()
  local buf = M.find_runner_buf()
  if buf and not win then
    vim.cmd("topleft vsplit | vertical resize 60 | terminal")
    win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buf)
  elseif not buf then
    -- No Runner buffer exists, create new terminal
    vim.cmd("topleft vsplit | vertical resize 60 | terminal")
    win = vim.api.nvim_get_current_win()
    buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(buf, "Runner")
  end
  term_win = win
  term_buf = buf
  return win
end

function M.use_runner_window(reason, cmd)
  local prev = vim.api.nvim_get_current_win()
  config.maybe_save_current_buffer(reason)
  local win = M.ensure_runner_window()
  vim.api.nvim_set_current_win(win)
  vim.api.nvim_win_set_buf(win, term_buf)
  if cmd then
    vim.fn.chansend(vim.b.terminal_job_id, "clear\n")
    vim.fn.chansend(vim.b.terminal_job_id, cmd .. "\n")
  end
  vim.cmd("wincmd p")
  vim.api.nvim_set_current_win(prev)
  
  return win
end

function M.run_current_file()
  local file = vim.fn.expand("%:p")
  if file == "" then return end

  local ft = vim.bo.filetype
  local cmd
  if ft == "python" then
    cmd = "python " .. vim.fn.fnameescape(file)
  elseif ft == "javascript" or ft == "javascriptreact" then
    cmd = "node " .. vim.fn.fnameescape(file)
  else
    print("No runner defined for filetype:", ft)
    return
  end

  M.use_runner_window("CodeRun", cmd)
end

function M.toggle_terminal()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_hide(term_win)
  elseif term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    vim.cmd("topleft vsplit | vertical resize 60")
    term_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(term_win, term_buf)
  else
    -- Create a new Runner terminal if none exists
    vim.cmd("topleft vsplit | vertical resize 60 | terminal")
    term_win = vim.api.nvim_get_current_win()
    term_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(term_buf, "Runner")
  end
end

function M.get_runner_lines()
  if not (term_buf and vim.api.nvim_buf_is_valid(term_buf)) then return {} end
  return vim.api.nvim_buf_get_lines(term_buf, 0, -1, false)
end

function M.use_for_test(cmd)
  M.use_runner_window("vim-test", cmd)
end

function M.run_last_command()
  if not (term_buf and vim.api.nvim_buf_is_valid(term_buf)) then
    print("No Runner terminal found")
    return
  end
  config.maybe_save_current_buffer("CodeRunLast")
  
  local prev = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(term_win)
  vim.fn.chansend(vim.b.terminal_job_id, "clear\n")
  vim.fn.chansend(vim.b.terminal_job_id, "\027[A\027[A\n") -- Up arrow + Enter
  vim.cmd("wincmd p")
  vim.api.nvim_set_current_win(prev)
end

return M


