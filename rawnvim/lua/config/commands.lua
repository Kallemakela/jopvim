vim.api.nvim_create_user_command("CopyLastMsg", function()
  local msgs = vim.split(vim.api.nvim_exec2("messages", { output = true }).output, "\n", { trimempty = true })
  vim.fn.setreg("+", msgs[#msgs])
end, {})

vim.api.nvim_create_user_command("DebugLastTest", function()
  local last_cmd = vim.g["test#last_command"] or ""
  if last_cmd == "" then
    print("No last test command found")
    return
  end
  local python_cmd, pytest_args = last_cmd:match("^(%S+)%s+(.*)")
  if not python_cmd or not pytest_args then
    print("Could not parse command:", last_cmd)
    return
  end
  -- Remove "-m pytest" from args since we're using module = 'pytest'
  local clean_args = pytest_args:gsub("^-m%s+pytest%s*", "")
  local args = {}
  for arg in clean_args:gmatch("%S+") do
    table.insert(args, arg)
  end
  local dap = require('dap')
  dap.run({
    type = 'python',
    request = 'launch',
    name = 'Debug Last Test',
    module = 'pytest',
    args = args,
    console = 'integratedTerminal',
    pythonPath = function()
      local conda = vim.fn.getenv('CONDA_PREFIX')
      if conda and conda ~= '' then
        return conda .. '/bin/python'
      end
      return vim.fn.exepath('python') or 'python'
    end,
  })
end, {})

vim.api.nvim_create_user_command("ReloadConfig", function()
  local patterns = {
    '^user', '^plugins', '^config',
    '^jopvim', '^coderunner', '^health%.jopvim',
  }
  for name, _ in pairs(package.loaded) do
    for _, pat in ipairs(patterns) do
      if name:match(pat) then
        package.loaded[name] = nil
        break
      end
    end
  end
  dofile(vim.env.MYVIMRC)
  -- Re-source plugin runtime files (including local/*/plugin/*.lua)
  vim.cmd('runtime! plugin/*.lua')
  print("Config reloaded.")
end, {})
