# jopvim

A Neovim plugin for working with Joplin notes.

## Commands

- `:JopCreateCategorizedNote` - Create a categorized Joplin note from current buffer
- `:JopOpen` - Open a Joplin note
- `:JopSearch` - Search and open a Joplin note (requires Telescope)
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
