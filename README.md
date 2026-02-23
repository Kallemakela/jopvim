# jopvim

A Neovim plugin for working with [Joplin](https://joplinapp.org) notes via the Web Clipper API.
Supports basic CRUD + quick note options for creating uncategorized or auto-categorized notes
+ full note body fuzzy search.

## Requirements

- Neovim 0.8+
- [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- Joplin desktop app with Web Clipper enabled
- `sqlite3` binary in PATH (for `:JopFuzzySearch` only)

## Setup

```lua
require("jopvim").setup({
  joplin_token = "your_token_here",        -- or set $JOPLIN_TOKEN env var
  joplin_url = "http://localhost:41184",   -- Joplin Web Clipper URL
  categorizer_url = "http://localhost:13131/category", -- external categorizer API
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
| `:JopOpen` | Browse recent notes in a paginated Telescope picker (20 per page, `<C-n>` for next page) |
| `:JopSearch` | Live full-text search via the Joplin API (min 2 chars) |
| `:JopFuzzySearch` | Fuzzy search over the local Joplin SQLite database with markdown preview |
| `:JopCreateUncategorizedNote` | Create a note in the configured uncategorized folder |
| `:JopCreateCategorizedNote` | Post buffer content to categorizer API, pick a category, create note |
| `:JopCreateTimeNote` | Create a note titled with the current datetime |
| `:JopDelete` | Delete the Joplin note open in the current buffer |
| `:JopCreateLink` | Pick a note via Telescope and insert a `[title](:/id)` link at cursor |
| `:JopOpenLink` | Open the Joplin link under the cursor in a new buffer |
| `:JopMeta` | Print the current buffer's note metadata (id, title) as JSON |

## Keymaps

Buffer-local keymaps applied to every opened Joplin note:

| Key | Action |
|---|---|
| `gd` | Open the Joplin link under cursor (`:JopOpenLink`) |
| `<leader>l` | Insert a link to another note at cursor (`:JopCreateLink`) |

## Note buffers

Notes open as `buftype=acwrite` buffers. Writing with `:w` saves the note back to Joplin via the API. If the first non-empty line changes, the note title is updated automatically and the buffer is renamed.

## Health check

```
:checkhealth jopvim
```
