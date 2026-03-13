# `lua/themes/` — Colorscheme plugins

Every `.lua` file here is a colorscheme plugin specification.
lazy.nvim auto-discovers and installs all of them.

Only **one** theme should have an active `vim.cmd.colorscheme(...)` call
at a time — the one you want as your startup default. All others are
installed and available via `:colorscheme` but don't activate themselves.

---

## How to switch themes permanently

**Option 1 — Keymap picker (easiest):**
Press `<Space>tt` in Normal mode. A floating picker lists all installed
themes. Arrow keys to navigate, Enter to apply. The choice is written to
`~/.local/share/nvim/theme` immediately and restored on next startup.

**Option 2 — Command line:**
```
:colorscheme tokyonight-moon
```
This also persists automatically — the `ColorScheme` autocmd in
`lua/config/theme.lua` saves the name to disk on every colorscheme change.

**Option 3 — Edit the files (manual default):**
To change which theme loads on fresh startup (before any choice is saved),
uncomment `vim.cmd.colorscheme(...)` in the theme you want and comment it
out in the currently active one (tokyonight.lua).

---

## Installed themes and their colorscheme names

### Tokyo Night — `tokyonight.lua`
Clean dark theme, blue/purple tones. Currently the **active default**.

| `:colorscheme` name | Description |
|---|---|
| `tokyonight` | Uses the style set in setup() — currently `storm` |
| `tokyonight-storm` | Dark blue-grey, slightly lighter than night |
| `tokyonight-moon` | Darker blue-purple, more contrast |
| `tokyonight-night` | Darkest variant |
| `tokyonight-day` | Light theme, warm tones |

---

### Fluoromachine — `fluoromachine.lua`
Neon-drenched synthwave aesthetic with a **glow effect**.
The glow adds a bloom/luminosity on top of syntax tokens — requires a
true-color terminal (`$TERM` should be `xterm-256color` or better).

| `:colorscheme` name | Description |
|---|---|
| `fluoromachine` | The main neon cyberpunk palette |
| `retrowave` | Retro synthwave, warmer tones |
| `delta` | Softer, more muted variant of the same palette |

> Note: all three names share the same plugin. The `theme` key inside
> `fluoromachine.setup()` selects the sub-palette. The `:colorscheme`
> name is always `fluoromachine` regardless of sub-palette — you switch
> sub-palettes by editing `theme = "retrowave"` in `fluoromachine.lua`.

---

### Catppuccin — `catppuccin.lua`
Soothing pastel theme. Four fully independent flavours — each is its own
`:colorscheme` name and has its own complete color palette.

| `:colorscheme` name | Description |
|---|---|
| `catppuccin` | Uses the flavour set in setup() — currently `mocha` |
| `catppuccin-latte` | Light theme, warm cream tones (the only light flavour) |
| `catppuccin-frappe` | Medium-dark, cool blue-grey |
| `catppuccin-macchiato` | Deeper, more saturated dark |
| `catppuccin-mocha` | Darkest, richest variant |

---

### Synthweave — `synthweave.lua`
SynthWave '84 port. Clean neon aesthetic, **intentionally no glow**.
Relies on treesitter for highlight groups — looks plain without it.

| `:colorscheme` name | Description |
|---|---|
| `synthweave` | Opaque background |
| `synthweave-transparent` | Transparent background |

---

### Cyberpunk — `cyperpunk.lua`
Dark cyberpunk palette.

| `:colorscheme` name | Description |
|---|---|
| `cyberpunk` | Single variant |

---

## How a theme plugin file is structured

```lua
return {
  {
    "author/theme-plugin.nvim",
    lazy = false,        -- REQUIRED: don't lazy-load colorschemes
    priority = 1000,     -- REQUIRED: load before other plugins

    config = function()
      require("theme-plugin").setup({
        -- options go here, BEFORE vim.cmd.colorscheme
      })

      -- Remove this comment and uncomment to make this the default:
      -- vim.cmd.colorscheme("theme-name")
    end,
  },
}
```

**Why `lazy = false` and `priority = 1000`?**
- `lazy = false` forces the plugin to load at startup rather than on demand.
  Without this, `:colorscheme theme-name` would fail until the plugin is triggered.
- `priority = 1000` makes lazy.nvim initialize this plugin before all others,
  so highlight groups are set before anything (like a statusline) renders.

**Why must `setup()` come before `vim.cmd.colorscheme`?**
`setup()` sets configuration options internally. `vim.cmd.colorscheme` then
reads those options when building the highlight table. If called in the wrong
order, your configuration is ignored and the theme's defaults are used.

---

## Adding a new theme

1. Create `lua/themes/mytheme.lua`
2. Return a lazy.nvim plugin spec with `lazy = false` and `priority = 1000`
3. Call `require("mytheme").setup({...})` if the plugin has one
4. Leave `vim.cmd.colorscheme` commented out (or activate it and deactivate another)
5. Run `:Lazy sync` to install
6. Switch to it with `<Space>tt` or `:colorscheme mytheme`
7. Add the name to the `M.themes` table in `lua/config/theme.lua` so it
   appears in the picker

---

## Recommended next explorations

- Try each installed theme for a day and see what feels right for long sessions
- Explore catppuccin-latte if you ever work in a bright environment
- The fluoromachine glow effect looks especially good in a terminal with a dark
  background and good true-color support (kitty, WezTerm, Alacritty)
