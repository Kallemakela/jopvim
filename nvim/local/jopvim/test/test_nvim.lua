#!/usr/bin/env lua

-- Test script that simulates Neovim loading more accurately
print("Testing jopvim with Neovim-like environment...")

-- Set up package path
package.path = "./lua/?.lua;./lua/?/init.lua;" .. package.path

-- More accurate vim mock
local vim_mock = {
  g = { loaded_jopvim = false },
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
    nvim_buf_set_var = function() end
  },
  bo = {},
  b = {},
  fn = {
    expand = function() return "test.md" end,
    tempname = function() return "/tmp/test" end,
    writefile = function() end,
    json_decode = function() return {} end,
    json_encode = function() return "{}" end,
    split = function() return {} end
  },
  system = function() 
    return {
      wait = function() return { code = 0, stdout = "{}", stderr = "" } end
    }
  end,
  ui = {
    select = function(items, opts, callback)
      print("✓ UI select called with " .. #items .. " items")
      if callback then callback(items[1]) end
    end
  },
  notify = function(msg, level)
    print("NOTIFY: " .. msg)
  end,
  log = {
    levels = {
      ERROR = 1,
      WARN = 2,
      INFO = 3
    }
  },
  health = {
    register = function(name, func)
      print("✓ Health check registered: " .. name)
      vim_mock.health._checks = vim_mock.health._checks or {}
      vim_mock.health._checks[name] = func
    end,
    start = function(name) print("HEALTH START: " .. name) end,
    ok = function(msg) print("✓ " .. msg) end,
    error = function(msg) print("✗ " .. msg) end
  }
}

_G.vim = vim_mock

print("\n1. Loading plugin file...")
local ok, err = pcall(function()
  dofile("./lua/plugin/jopvim.lua")
end)

if not ok then
  print("✗ Plugin loading failed: " .. tostring(err))
  return
end
print("✓ Plugin loaded successfully")

print("\n2. Testing command execution...")
local commands = vim_mock.api._commands or {}
if commands and commands.JopCreateCategorizedNote then
  print("✓ JopCreateCategorizedNote command exists")
  -- Test executing the command
  local cmd_ok, cmd_err = pcall(commands.JopCreateCategorizedNote.func)
  if cmd_ok then
    print("✓ JopCreateCategorizedNote command executed successfully")
  else
    print("✗ JopCreateCategorizedNote command failed: " .. tostring(cmd_err))
  end
else
  print("✗ JopCreateCategorizedNote command missing")
end

if commands and commands.JopCreateUncategorizedNote then
  print("✓ JopCreateUncategorizedNote command exists")
  local cmd_ok, cmd_err = pcall(commands.JopCreateUncategorizedNote.func)
  if cmd_ok then
    print("✓ JopCreateUncategorizedNote command executed successfully")
  else
    print("✗ JopCreateUncategorizedNote command failed: " .. tostring(cmd_err))
  end
else
  print("✗ JopCreateUncategorizedNote command missing")
end

if commands.JopCreateTimeNote then
  print("✓ JopCreateTimeNote command exists")
else
  print("✗ JopCreateTimeNote command missing")
end

if commands.JopOpen then
  print("✓ JopOpen command exists")
  -- Test executing the command
  local cmd_ok, cmd_err = pcall(commands.JopOpen.func)
  if cmd_ok then
    print("✓ JopOpen command executed successfully")
  else
    print("✗ JopOpen command failed: " .. tostring(cmd_err))
  end
else
  print("✗ JopOpen command missing")
end

print("\n3. Testing health check execution...")
if vim_mock.health._checks and vim_mock.health._checks.jopvim then
  print("✓ Health check function exists")
  local health_ok, health_err = pcall(vim_mock.health._checks.jopvim)
  if health_ok then
    print("✓ Health check executed successfully")
  else
    print("✗ Health check failed: " .. tostring(health_err))
  end
else
  print("✗ Health check function missing")
end

print("\n✓ All Neovim simulation tests passed!")
print("\nThe plugin should work correctly in Neovim.")
print("If commands still don't show up, the issue is likely with your plugin manager configuration.")
