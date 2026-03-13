# `lua/config/` — Core editor configuration

This folder configures the **editor itself** — independent of any plugins.
You can think of it as your "personal preferences" folder.
Nothing here installs or requires a plugin to work.

---

## Files

### `options.lua` — editor settings

Sets `vim.opt.*` values. These are the Neovim equivalent of VSCode's `settings.json`.

```
:help vim.opt       ← full documentation of every option
:help options       ← the underlying option reference
```

**Settings currently active and what they do:**

| Option | Value | What it means |
|---|---|---|
| `number` | true | Show line numbers in the gutter |
| `relativenumber` | true | Lines above/below show their distance, not their absolute number. Helps with `5j` to jump 5 lines. |
| `mouse` | 'a' | Mouse works everywhere (click to move cursor, scroll, resize splits) |
| `undofile` | true | Undo history is saved to disk — you can undo changes from a previous session |
| `ignorecase` + `smartcase` | true | Searching is case-insensitive unless you type a capital letter |
| `signcolumn` | 'yes' | The gutter column (where `+` / `~` git signs and LSP error icons appear) is always visible |
| `cursorline` | true | The current line has a subtle background highlight |
| `scrolloff` | 10 | The cursor never gets closer than 10 lines to the edge of the screen |
| `tabstop` / `shiftwidth` | 2 | Tabs and indentation use 2 spaces (common in JS/TS/Lua) |
| `expandtab` | true | Pressing Tab inserts spaces, not a tab character |

**Easy first customizations to try:**

```lua
-- Change tab size to 4 (common in Python, Go)
opt.tabstop = 4
opt.shiftwidth = 4

-- Disable relative numbers if they feel confusing
opt.relativenumber = false

-- Keep more context when scrolling
opt.scrolloff = 5

-- Wrap long lines visually (does not insert newlines)
opt.wrap = true

-- Show whitespace characters (tabs, trailing spaces)
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
```

---

### `keymaps.lua` — key bindings

Defines custom key mappings with `vim.keymap.set()`.

**Reading a keymap entry:**
```lua
set("n", "<leader>tt", function() theme.pick() end, { desc = "[T]heme picker" })
--   ^     ^             ^                              ^
--   mode  keys          what to do                    description shown in which-key
```

Modes: `"n"` = Normal, `"i"` = Insert, `"v"` = Visual, `"x"` = Visual block.

`<leader>` is the Space key (set in `init.lua` as `vim.g.mapleader = ' '`).

**Useful mappings to add yourself (examples):**

```lua
-- Save with Ctrl-S (familiar from VSCode)
set({ "n", "i" }, "<C-s>", "<cmd>w<cr>", { desc = "Save file" })

-- Close the current buffer
set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- Open the config directory quickly
set("n", "<leader>ec", "<cmd>e ~/.config/nvim/<cr>", { desc = "Edit config" })

-- Move selected lines up/down in Visual mode (like Alt-Arrow in VSCode)
set("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
set("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })
```

**How `<leader>` works:**
Space is pressed first, then the rest of the sequence. `<leader>tt` means:
press Space, then t, then t. You have 300ms between keys (set by `timeoutlen`).

---

### `autocmds.lua` — automatic actions on events

Runs Lua code in response to Neovim events — similar to VSCode's `onDidSave`,
`onDidChangeActiveEditor`, etc.

**Currently configured:**
- `TextYankPost`: briefly highlights yanked (copied) text so you can see what was copied.

**Useful autocmds to add:**

```lua
-- Auto-format on save (once you have conform.nvim installed)
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function() require("conform").format({ async = false }) end,
})

-- Set different tab sizes per language
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false   -- Go uses real tabs
  end,
})

-- Highlight the line when a window is active, turn it off when not
vim.api.nvim_create_autocmd({ "WinEnter", "WinLeave" }, {
  callback = function(ev)
    vim.opt_local.cursorline = ev.event == "WinEnter"
  end,
})
```

**How autocmd events work:**
```
vim.api.nvim_create_autocmd("EventName", {
  pattern = "*.lua",     ← optional: only files matching this glob
  callback = function()  ← the code to run
    ...
  end,
})
```
Full list of events: `:help autocmd-events`

---

### `theme.lua` — persistent colorscheme switcher

Manages saving and restoring your active colorscheme across Neovim sessions.
Writes the current theme name to `~/.local/share/nvim/theme` on every
`:colorscheme` call and re-reads it on startup.

See `lua/themes/README.md` for the full theme list and how to switch.

---

## What else belongs in `config/`?

Good candidates for future files here:

- `lua/config/highlights.lua` — custom highlight group tweaks that don't belong to a specific theme
- `lua/config/commands.lua` — custom user commands (`vim.api.nvim_create_user_command`)
- `lua/config/diagnostics.lua` — LSP diagnostic display configuration (icons, virtual text style)
