#!/usr/bin/env bash
set -euo pipefail

# Simple headless sanity check for lazy.nvim and :checkhealth
# Usage: ./test/headless_health.sh [path-to-init.lua]

INIT_LUA="${1:-$HOME/.config/nvim/init.lua}"

if [[ ! -f "$INIT_LUA" ]]; then
  echo "init.lua not found: $INIT_LUA" >&2
  exit 2
fi

TMP_OUT="$(mktemp)"
trap 'rm -f "$TMP_OUT"' EXIT

NVIM_BIN="${NVIM_BIN:-nvim}"

# Run Neovim headless: touch lazy, then run checkhealth, then quit
"$NVIM_BIN" --headless -u "$INIT_LUA" \
  "+lua local ok, lazy = pcall(require,'lazy'); if ok and type(lazy)=='table' then local st_ok, stats = pcall(function() return lazy.stats end); if st_ok and type(stats)=='function' then local ss = stats(); print('LAZY_STATS OK loaded='..tostring(ss.loaded)..' count='..tostring(ss.count)) else print('LAZY_STATS OK (no stats fn)') end else print('LAZY_STATS FAIL') end" \
  "+silent! checkhealth" \
  "+qa" | tee "$TMP_OUT"

# Fail if health reports errors
if grep -E "(^\s*ERROR|^\s*✗)" -q "$TMP_OUT"; then
  echo "checkhealth reported errors" >&2
  exit 1
fi

echo "Headless health: OK"

