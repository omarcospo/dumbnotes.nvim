# DumbNotes.nvim

DumbNotes.nvim is a simple Neovim plugin for managing and searching your
notes.

## Features

- Create new notes in any format you choose (defaults to markdown)
- Delete existing notes
- List all notes using fd
- Search through notes using ripgrep

## Installation

### Using Lazy

Add the following to your `init.lua`

```lua
{
  "omarcospo/dumbnotes.nvim",
  dependencies = "nvim-telescope/telescope.nvim",
}
```

## Usage

### Commands

- `:DumbNotes` - List all notes in the notes directory.
- `:DumbNotesGrep` - Search through notes using ripgrep.

### Keybindings

Within the Telescope prompt for notes:

- `<CR>` - Open the selected note.
- `<C-n>` - Create a new note.
- `<C-d>` - Delete the selected note.
- `<C-f>` - Search notes using ripgrep.

## Default config

Add the following setup code to your `init.lua` or `init.vim`:

```lua
require('dumbnotes').setup({
  notes_format = "md", -- Format of the notes
  notes_path = "~/Notes", -- Path to the notes directory
  find_recursively = false, -- Find notes recursively in path
  mappings = {
    new_note_key = "<C-n>", -- Keybinding to create a new note
    delete_note_key = "<C-d>", -- Keybinding to delete a note
    search_note_key = "<C-f>", -- Keybinding to search notes
  },
})
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
