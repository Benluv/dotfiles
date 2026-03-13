# `lua/` — The Lua module directory

Neovim automatically adds this directory to its Lua module search path.
That means any file at `lua/foo/bar.lua` can be loaded with `require('foo.bar')`.

This is a Neovim convention — not something lazy.nvim invented.

---

## Subdirectories

| Directory | Purpose |
|---|---|
| `config/` | Core editor configuration (settings, keymaps, autocommands) |
| `plugins/` | Non-theme plugin specifications loaded by lazy.nvim |
| `themes/` | Colorscheme plugin specifications loaded by lazy.nvim |

---

## What goes here vs in the subdirectories

**Goes directly in `lua/` (rare):** top-level utility modules that don't fit
neatly into config, plugins, or themes — for example a shared helper library
you want to `require('utils')` from multiple places.

**Goes in `lua/config/`:** anything that configures the editor itself — options,
keymaps, autocommands, the theme persistence module.

**Goes in `lua/plugins/`:** plugin specs for tools and features (LSP, file
search, git, completions, statusline, etc.).

**Goes in `lua/themes/`:** plugin specs specifically for colorschemes.

---

## Why are plugins split into `plugins/` and `themes/`?

Both are loaded the same way (`{ import = 'plugins' }` and `{ import = 'themes' }`
in `init.lua`). The split is purely organisational — it makes it easy to see
at a glance which files are about appearance and which are about functionality.
You could merge them into one folder with no technical consequence.

---

## How `require()` resolves paths

```
require('config.options')   →  lua/config/options.lua
require('plugins.lsp')      →  lua/plugins/lsp.lua   (not normally required directly)
require('config.theme')     →  lua/config/theme.lua
```

lazy.nvim loads plugin specs by scanning the directory, not by `require()`,
so you never call `require('themes.tokyonight')` yourself.
