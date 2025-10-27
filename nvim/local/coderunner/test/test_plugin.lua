#!/usr/bin/env lua

-- Test script to check if coderunner loads properly headlessly
print("Testing coderunner plugin loading...")

-- Set up package path to find our plugin
package.path = "./lua/?.lua;./lua/?/init.lua;" .. package.path

-- Mock vim functions that the plugin needs
local vim_mock = {
  g = {},
  api = {
    nvim_create_user_command = function(name, func, opts)
      print("✓ Command registered: " .. name)
      return true
    end,
    nvim_get_commands = function()
      return {
        CodeRun = { name = "CodeRun" },
        CodeToggle = { name = "CodeToggle" },
        OpenLinks = { name = "OpenLinks" }
      }
    end,
    nvim_get_current_buf = function() return 1 end,
    nvim_buf_get_lines = function() return {} end,
    nvim_buf_set_lines = function() end,
    nvim_buf_set_name = function() end,
    nvim_create_autocmd = function() end,
    nvim_buf_set_var = function() end,
    nvim_get_current_buf = function() return 1 end,
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

-- Set global vim
_G.vim = vim_mock

-- Test loading the plugin
print("\n1. Testing plugin file loading...")
local ok, err = pcall(function()
  dofile("./plugin/coderunner.lua")
end)

if not ok then
  print("✗ Plugin file failed to load: " .. tostring(err))
  return
end
print("✓ Plugin file loaded successfully")

print("\n2. Testing main module loading...")
local ok, coderunner = pcall(require, "coderunner")
if not ok then
  print("✗ Main module failed to load: " .. tostring(coderunner))
  return
end
print("✓ Main module loaded successfully")

print("\n3. Testing function availability...")
if coderunner.run_current_file then
  print("✓ run_current_file function exists")
else
  print("✗ run_current_file function missing")
end

if coderunner.toggle_terminal then
  print("✓ toggle_terminal function exists")
else
  print("✗ toggle_terminal function missing")
end

print("\n✓ All tests completed!")
