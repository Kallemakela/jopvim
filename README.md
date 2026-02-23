# jopvim

A Neovim plugin for working with [Joplin](https://joplinapp.org) notes via the Web Clipper API.
Supports basic CRUD + quick note options for creating uncategorized or auto-categorized notes + full note body fuzzy search.

https://github.com/user-attachments/assets/06cd9c3c-f0c2-4897-aa20-eb58240666dd

## Requirements

- Neovim 0.8+
- [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- Joplin desktop app with Web Clipper enabled
- `sqlite3` binary in PATH (for `:JopFuzzySearch` only)
- [joplin-text-server](https://github.com/Kallemakela/joplin-text-server) (optional, for `:JopCreateCategorizedNote`)

## Setup

```lua
require("jopvim").setup({
  joplin_token = "your_token_here",        -- or set $JOPLIN_TOKEN env var
  joplin_url = "http://localhost:41184",   -- Joplin Web Clipper URL
  categorizer_url = "http://localhost:13131/category", -- external categorizer API (see https://github.com/Kallemakela/joplin-text-server)
  title_strategy = "first_non_empty_line", -- or "filename"
  sqlite_path = "~/.config/joplin-desktop/database.sqlite",
  fuzzy_min_chars = 2,
  fuzzy_max_rows = 100000,
  uncategorized_folder_id = "your_folder_id",
  time_note_folder_id = "your_folder_id",
})
```

## Commands

| Command | Description |
|---|---|
| `:JopOpen` | Open notes, C-n/C-p pagination, C-f to cycle filter (all/todo/todo_incomplete/completed), C-d to toggle todo completion |
| `:JopFuzzySearch` | Fuzzy search over the local Joplin SQLite database with markdown preview |
| `:JopCreateUncategorizedNote` | Create a note in the configured uncategorized folder |
| `:JopCreateCategorizedNote` | Post buffer content to categorizer API, pick a category, create note |
| `:JopCreateTimeNote` | Create a note titled with the current datetime |
| `:JopDelete` | Delete the Joplin note open in the current buffer |
| `:JopCreateLink` | Pick a note via Telescope and insert a `[title](:/id)` link at cursor |
| `:JopOpenLink` | Open the Joplin link under the cursor in a new buffer |
| `:JopMeta` | Print the current buffer's note metadata (id, title) as JSON |
| `:JopNote [content] [folder_id=...]` | Create a note from args, visual selection, or empty; accepts `folder_id=` flag |

## Keymaps

Buffer-local keymaps applied to every opened Joplin note:

| Key | Action |
|---|---|
| `gd` | Open the Joplin link under cursor (`:JopOpenLink`) |
| `<leader>l` | Insert a link to another note at cursor (`:JopCreateLink`) |

Keymaps active inside the `:JopOpen` picker:

| Key | Action |
|---|---|
| `<C-n>` | Next page |
| `<C-p>` | Previous page |
| `<C-f>` | Cycle filter: all -> todo -> todo_incomplete -> completed |
| `<C-d>` | Toggle todo completion on the selected entry |

## Note buffers

Notes open as `buftype=acwrite` buffers. Writing with `:w` saves the note back to Joplin via the API. If the first non-empty line changes, the note title is updated automatically and the buffer is renamed. Title update behavior is controlled by `title_update_mode`: `"silent"` (default), `"notify"`, or `"confirm"`.

## Session restore

Note buffers survive a Vim session save/restore. On `SessionLoadPost`, any buffer matching a Joplin note pattern is re-fetched and re-opened from Joplin.

## Health check

```
:checkhealth jopvim
```
