-- Dap conf before dapui, uses runner
local dap = require('dap')
local runner = require("coderunner.runner")

-- Use runner window
dap.defaults.fallback.terminal_win_cmd = function()
  local win = runner.ensure_runner_window()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(win, buf)
  return buf, win
end

-- Find DAP terminal buffer
local function find_dap_buffer()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local buf_name = vim.api.nvim_buf_get_name(buf)
    if vim.bo[buf].buftype == 'terminal' and string.find(buf_name, "%[dap%-terminal%]") then
      return buf
    end
  end
  return nil
end

-- Close DAP terminal buffer
local function close_dap_buffer()
  local buf = find_dap_buffer()
  if buf then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
end

-- Focus when running
dap.listeners.after['event_initialized']['move_dap_buffer'] = function(session, body)
  local buf = find_dap_buffer()
  if buf then
    local win = runner.ensure_runner_window()
    vim.api.nvim_win_set_buf(win, buf)
  end
end

-- Use custom env that has debugpy
local dbg = vim.fn.exepath('conda') ~= '' and (vim.fn.systemlist('conda run -n w which python')[1]) or vim.fn.expand('~/mambaforge/envs/w/bin/python')
dap.adapters.python = {
  type = 'executable',
  command = dbg,
  args = { '-m', 'debugpy.adapter' },
}

dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = 'Launch file',
    program = '${file}',
    console = 'integratedTerminal',
    pythonPath = function()
      local conda = vim.fn.getenv('CONDA_PREFIX')
      if conda and conda ~= '' then
        return conda .. '/bin/python'
      end
      -- Fallback to system python
      return vim.fn.exepath('python') or 'python'
    end,
  },
  {
    type = 'python',
    request = 'launch',
    name = 'Debug Test',
    module = 'pytest',
    args = { '${file}', '-v' },
    console = 'integratedTerminal',
    pythonPath = function()
      local conda = vim.fn.getenv('CONDA_PREFIX')
      if conda and conda ~= '' then
        return conda .. '/bin/python'
      end
      return vim.fn.exepath('python') or 'python'
    end,
  },
}

-- Store original keymaps
local original_keymaps = {}

-- Function to save current keymaps before setting debug ones
local function save_original_keymaps()
  local keys = {'<F5>', '<F10>', '<F11>', '<F12>', '<Leader>b', '<Leader>B', '<Leader>dr', '<Leader>dl'}
  
  for _, key in ipairs(keys) do
    local existing = vim.fn.maparg(key, 'n', false, true)
    if existing.lhs ~= '' then
      original_keymaps[key] = existing
    else
      original_keymaps[key] = nil -- No original mapping
    end
  end
end

dap.listeners.after.event_initialized['dap_keymaps'] = function()
  local opts = { noremap = true, silent = true, buffer = true }
  vim.keymap.set('n', '<Down>', function()
    vim.cmd('normal! oprint("DEBUG: " .. tostring())')
    vim.cmd('normal! A')
  end, opts)
end

-- Command to close DAP buffer
vim.api.nvim_create_user_command("CloseDapBuffer", close_dap_buffer, {})

dap.listeners.after.event_terminated['dap_keymaps'] = function()
  -- Restore original keymaps
end