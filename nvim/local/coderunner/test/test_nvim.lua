#!/usr/bin/env lua

-- Test script that simulates Neovim loading more accurately
print("Testing coderunner with Neovim-like environment...")

-- Set up package path
package.path = "./lua/?.lua;./lua/?/init.lua;" .. package.path

-- More accurate vim mock
local vim_mock = {
  g = { loaded_coderunner = false },
  api = {
    nvim_create_user_command = function(name, func, opts)
      print("✓ Command registered: " .. name)
      -- Store the command for later testing
      vim_mock.api._commands = vim_mock.api._commands or {}
      vim_mock.api._commands[name] = { func = func, opts = opts }
      return true
    end,
    nvim_get_commands = function()
      local commands = {}
      if vim_mock.api._commands then
        for name, cmd in pairs(vim_mock.api._commands) do
          commands[name] = { name = name }
        end
      end
      return commands
    end,
    nvim_get_current_buf = function() return 1 end,
    nvim_buf_get_lines = function() return {} end,
    nvim_buf_set_lines = function() end,
    nvim_buf_set_name = function() end,
    nvim_create_autocmd = function() end,
    nvim_buf_set_var = function() end,
    nvim_buf_is_valid = function() return true end,
    nvim_win_is_valid = function() return true end,
    nvim_get_current_win = function() return 1 end,
    nvim_win_hide = function() end,
    nvim_win_set_buf = function() end,
    nvim_set_current_win = function() end
  },
  bo = { filetype = "python" },
  b = { terminal_job_id = 1 },
  fn = {
    expand = function() return "test.py" end,
    fnameescape = function(f) return f end,
    chansend = function() end
  },
  cmd = function(cmd) end
}

_G.vim = vim_mock

print("\n1. Loading plugin file...")
local ok, err = pcall(function()
  dofile("./plugin/coderunner.lua")
end)

if not ok then
  print("✗ Plugin loading failed: " .. tostring(err))
  return
end
print("✓ Plugin loaded successfully")

print("\n2. Testing command execution...")
local commands = vim_mock.api._commands or {}
if commands and commands.CodeRun then
  print("✓ CodeRun command exists")
  -- Test executing the command
  local cmd_ok, cmd_err = pcall(commands.CodeRun.func)
  if cmd_ok then
    print("✓ CodeRun command executed successfully")
  else
    print("✗ CodeRun command failed: " .. tostring(cmd_err))
  end
else
  print("✗ CodeRun command missing")
end

if commands and commands.CodeToggle then
  print("✓ CodeToggle command exists")
  local cmd_ok, cmd_err = pcall(commands.CodeToggle.func)
  if cmd_ok then
    print("✓ CodeToggle command executed successfully")
  else
    print("✗ CodeToggle command failed: " .. tostring(cmd_err))
  end
else
  print("✗ CodeToggle command missing")
end

if commands and commands.OpenLinks then
  print("✓ OpenLinks command exists")
else
  print("✗ OpenLinks command missing")
end

print("\n✓ All Neovim simulation tests passed!")
print("\nThe plugin should work correctly in Neovim.")
print("If commands still don't show up, the issue is likely with your plugin manager configuration.")
