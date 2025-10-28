#!/usr/bin/env lua

-- Test script to check if jopvim loads properly headlessly
print("Testing jopvim plugin loading...")

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
        JopCreateCategorizedNote = { name = "JopCreateCategorizedNote" },
        JopOpen = { name = "JopOpen" },
        JopCreateUncategorizedNote = { name = "JopCreateUncategorizedNote" },
        JopCreateTimeNote = { name = "JopCreateTimeNote" }
      }
    end,
    nvim_get_current_buf = function() return 1 end,
    nvim_buf_get_lines = function() return {} end,
    nvim_buf_set_lines = function() end,
    nvim_buf_set_name = function() end,
    nvim_create_autocmd = function() end,
    nvim_buf_set_var = function() end,
    nvim_get_current_buf = function() return 1 end,
    nvim_win_set_buf = function() end,
    nvim_win_set_cursor = function() end,
    nvim_create_buf = function() return 2 end
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
    end,
    start = function(name) print("HEALTH START: " .. name) end,
    ok = function(msg) print("✓ " .. msg) end,
    error = function(msg) print("✗ " .. msg) end
  }
}

-- Set global vim
_G.vim = vim_mock

-- Test loading the plugin
print("\n1. Testing plugin file loading...")
local ok, err = pcall(function()
  dofile("./lua/plugin/jopvim.lua")
end)

if not ok then
  print("✗ Plugin file failed to load: " .. tostring(err))
  return
end
print("✓ Plugin file loaded successfully")

print("\n2. Testing main module loading...")
local ok, jopvim = pcall(require, "jopvim")
if not ok then
  print("✗ Main module failed to load: " .. tostring(jopvim))
  return
end
print("✓ Main module loaded successfully")

print("\n3. Testing function availability...")
if jopvim.create_categorized_note then
  print("✓ create_categorized_note function exists")
else
  print("✗ create_categorized_note function missing")
end

if jopvim.open_notes then
  print("✓ open_notes function exists")
else
  print("✗ open_notes function missing")
end

if jopvim.setup then
  print("✓ setup function exists")
else
  print("✗ setup function missing")
end

print("\n4. Testing dependencies...")
local deps = {
  "jopvim.config",
  "jopvim.joplinapi",
  "jopvim.note", 
  "jopvim.buffer",
  "jopvim.categorize",
  "jopvim.utils",
  "jopvim.http"
}

for _, dep in ipairs(deps) do
  local ok, _ = pcall(require, dep)
  if ok then
    print("✓ " .. dep .. " loaded")
  else
    print("✗ " .. dep .. " failed to load")
  end
end

print("\n5. Testing health check...")
local health_ok, health = pcall(require, "jopvim.health")
if health_ok then
  print("✓ Health module loaded")
  if health.check then
    print("✓ Health check function exists")
    health.check()
  else
    print("✗ Health check function missing")
  end
else
  print("✗ Health module failed to load")
end

print("\n6. Testing note metadata seeding...")
local note_ok, note = pcall(require, "jopvim.note")
if note_ok then
  local sample = { id = "id123", title = "Title", body = "Hello" }
  if note.open_note then
    local ok_open = pcall(note.open_note, sample)
    if ok_open then
      local meta = vim.b[2] and vim.b[2].jopvim_meta or {}
      if meta.id == sample.id and meta.title == sample.title then
        print("✓ Metadata set on created buffer")
      else
        print("✗ Metadata missing or incorrect on created buffer")
      end
    else
      print("✗ open_note failed to execute")
    end
  end
else
  print("✗ note module failed to load")
end

print("\n✓ All tests completed!")
