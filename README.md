# jopvim

A Neovim plugin for working with Joplin notes. 

## Features

- Automatically categorize notes based on the content
  - Uses a LM to embed content and KNN to find the closest categories
- Multiple search modes:
  - Telescope default fuzzy search on titles
  - Fuzzy search from body content
  - Search closest notes by embedding similarity
- All other Joplin features, most importantly:
  - Free sync if you have any cloud storage account
  - A synced phone app
  - Links
  - Tags

## Commands

- `:JopCreateCategorizedNote` - Create a categorized Joplin note from current buffer
- `:JopOpen` - Open or search Joplin notes (shows all notes by default, type to filter)
- `:JopFuzzySearch` - Fuzzy search Joplin notes from body content
- `:JopDelete` - Delete the currently open Joplin note

## Setup

```lua
require("jopvim").setup({
  joplin_token = "your_token_here",
  joplin_url = "http://localhost:41184",
  categorizer_url = "http://localhost:8080",
  title_strategy = "first_line" -- or "filename"
})
```

### Requirements

- Neovim 0.8+
- Telescope: `nvim-telescope/telescope.nvim` (required for `:JopSearch` live results)
