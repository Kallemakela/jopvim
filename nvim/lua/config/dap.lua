local dapui = require("dapui")
local dap = require('dap')
dapui.setup()

-- Use custom env that has debugpy
local dbg = vim.fn.exepath('conda') ~= '' and (vim.fn.systemlist('conda run -n w which python')[1]) or vim.fn.expand('~/mambaforge/envs/w/bin/python')
dap.adapters.python = {
  type = 'executable',
  command = dbg,
  args = { '-m', 'debugpy.adapter' },
}

-- Global keymaps
vim.keymap.set("n", "<leader>da", "<cmd>DapToggleBreakpoint<cr>", { desc = "Toggle breakpoint", silent = true })

-- Active keymaps
function add_keymaps()
  vim.keymap.set('n', '<Down>', dap.step_over, { buffer = bufnr, silent = true })
  vim.keymap.set('n', '<Right>', dap.step_into, { buffer = bufnr, silent = true })
  vim.keymap.set('n', '<Left>', dap.step_out, { buffer = bufnr, silent = true })
  vim.keymap.set('n', '<Up>', dap.continue, { buffer = bufnr, silent = true })
  vim.keymap.set('n', '<leader><Up>', dap.restart_frame, { buffer = bufnr, silent = true })
  -- vim.keymap.set('n', '<leader><Left>', dap.step_back, { buffer = bufnr, silent = true })
  -- vim.keymap.set('n', '<leader><Right>', dap.step_forward, { buffer = bufnr, silent = true })
  vim.keymap.set('n', '<leader><Down>', dap.terminate, { buffer = bufnr, silent = true })
end

-- Remove active keymaps
-- NTH: save original keymaps before setting debug ones and restore them after, not needed here since all keymaps are unique
function remove_keymaps()
  pcall(vim.keymap.del, 'n', '<Down>', { buffer = bufnr })
  pcall(vim.keymap.del, 'n', '<Right>', { buffer = bufnr })
  pcall(vim.keymap.del, 'n', '<Left>', { buffer = bufnr })
  pcall(vim.keymap.del, 'n', '<Up>', { buffer = bufnr })
  pcall(vim.keymap.del, 'n', '<leader><Up>', { buffer = bufnr })
  pcall(vim.keymap.del, 'n', '<leader><Down>', { buffer = bufnr })
end

function on_start()
  dapui.open()
  add_keymaps()
end
function on_terminate()
  dapui.close()
  remove_keymaps()
end

dap.listeners.before.event_initialized["dapui_config"] = function() 
  on_start()
end
dap.listeners.before.event_terminated["dapui_config"] = function() 
  on_terminate()
end
dap.listeners.before.event_exited["dapui_config"] = function() 
  on_terminate()
end

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

