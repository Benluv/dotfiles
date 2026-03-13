# Neovim Config — Overview & Learning Plan

> This config uses **lazy.nvim** as the plugin manager.
> Everything is written in Lua. If you know JavaScript, Lua will feel
> very familiar — it is a small, dynamic language with tables instead of objects.

---

## Directory structure

```
nvim/
├── init.lua              ← Entry point. Bootstraps lazy.nvim and loads everything.
├── lazy-lock.json        ← Auto-generated lockfile (like package-lock.json). Don't edit by hand.
├── lsp/                  ← Per-language LSP server configuration files.
│   └── README.md
└── lua/                  ← All your Lua config lives here.
    ├── README.md
    ├── config/           ← Core editor settings (options, keymaps, autocmds, theme).
    │   └── README.md
    ├── plugins/          ← Non-theme plugins (LSP, syntax, search, git, etc.).
    │   └── README.md
    └── themes/           ← Colorscheme plugins.
        └── README.md
```

**Why is everything under `lua/`?**
Neovim automatically adds `lua/` to its Lua module search path. That means
`require('config.options')` resolves to `lua/config/options.lua`. The folder
name `lua/` is a Neovim convention, not a lazy.nvim thing.

---

## How the config loads (reading `init.lua`)

```
init.lua
  ├── require('config.options')      ← editor settings
  ├── require('config.keymaps')      ← key bindings (+ theme picker)
  ├── require('config.autocmds')     ← automatic actions on events
  └── require('lazy').setup(...)
        ├── { import = 'plugins' }   ← loads every file in lua/plugins/
        └── { import = 'themes' }   ← loads every file in lua/themes/
```

lazy.nvim **auto-discovers** every `.lua` file in `plugins/` and `themes/`
and treats each as a plugin specification. You never need to manually list them.

---

## What is already installed

| Plugin | What it does | VSCode equivalent |
|---|---|---|
| **nvim-lspconfig** | Connects Neovim to language servers | IntelliSense engine |
| **mason.nvim** | Installs language servers with one command | Extension marketplace (backend) |
| **nvim-treesitter** | Accurate syntax highlighting via parse trees | Semantic highlighting |
| **snacks.nvim** | Picker, dashboard, file search, notifications | Quick Open + Command Palette |
| **opencode.lua** | AI coding assistant | GitHub Copilot / Cursor |
| **tokyonight** + others | Colorschemes | Theme extensions |

---

## Your personal roadmap

Based on your setup (JS/TS + HTML/CSS + Shell, coming from VSCode) here is a
concrete ordered action plan. Each step is designed to take 30–60 minutes and
give you something immediately visible to show for it.

---

### Before you start — install a Nerd Font

A **Nerd Font** is a regular programming font patched with thousands of small
icons. Plugins like the file explorer, status bar, and LSP diagnostics use
these icons. Without one, you get boxes or question marks instead.

Since you use **Powerlevel10k (p10k)**, the font it recommends is
**MesloLGS NF** — you may already have it configured in your terminal.

Check by running this in your terminal:

```bash
echo $TERM && fc-list | grep -i meslo
```

If nothing shows, install it:

```bash
# Download the four MesloLGS NF fonts from the p10k repo, then:
fc-cache -fv
```

Then set "MesloLGS NF" as the font in your terminal emulator's settings.
Your Neovim config will automatically detect and use Nerd Font glyphs once
the font is set.

> If you're not sure which terminal app you use: on GNOME, go to
> **Preferences → Profile → Text → Custom font**. On Kitty/Alacritty,
> it's in `~/.config/kitty/kitty.conf` or `~/.config/alacritty/alacritty.toml`.

---

### Step 1 — Status bar (15 min)

**Why first:** it's the smallest change with the most visible result.
Immediately shows you your mode, file, git branch, and LSP errors.

Create `lua/plugins/statusline.lua` (the snippet is in `lua/plugins/README.md`),
then run `:Lazy sync`.

---

### Step 2 — File explorer (20 min)

**Why second:** this is the VSCode sidebar you're used to. Once it's there,
navigating projects feels familiar again.

Create `lua/plugins/explorer.lua` (snippet in `lua/plugins/README.md`),
run `:Lazy sync`, then press `<Space>e` to toggle it.

---

### Step 3 — Git gutter (15 min)

**Why third:** you're clearly comfortable with git. Seeing `+` / `~` in the
gutter makes it obvious what you've changed without leaving the editor.

Create `lua/plugins/gitsigns.lua` (snippet in `lua/plugins/README.md`).
Press `<leader>gb` to toggle inline git blame on the current line.

---

### Step 4 — Set up JS/TS language server (20 min)

**Why fourth:** you write JS/TS daily. At this point the LSP is already running
for Lua and Python. Adding `ts_ls` gives you autocompletion, go-to-definition,
and rename refactor for your primary language.

Instructions are in `lsp/README.md` under "JavaScript / TypeScript".
Run `:MasonInstall typescript-language-server`, then add `ts_ls` in `lsp.lua`.

---

### Step 5 — Better autocomplete UI (20 min)

**Why fifth:** native 0.11 completion works but has no icons, no snippet support,
and no documentation preview. `blink.cmp` adds all of that with minimal config.

Snippet is in `lua/plugins/README.md`. Remember to disable the native completion
line in `lsp.lua` as the snippet notes.

---

### Step 6 — Auto-format on save (20 min)

**Why sixth:** you use Prettier in VSCode. `conform.nvim` brings that here.
After installing, saving a JS/TS/HTML/CSS file will run Prettier automatically.

Snippet is in `lua/plugins/README.md`. Install Prettier via Mason:
`:MasonInstall prettier`

---

### Step 7 — Integrated terminal (10 min)

**Why seventh:** `toggleterm.nvim` gives you a floating terminal on `Ctrl-\`.
Since you're on zsh + p10k, it will open your full configured shell.

Snippet is in `lua/plugins/README.md`.

---

### After all 7 steps — what you'll have

A Neovim that does everything your VSCode did, plus modal editing:
- File tree sidebar
- Git gutter + inline blame
- JS/TS + HTML/CSS + Shell + Lua + Python language intelligence
- Autocomplete with icons and documentation preview
- Format on save (Prettier)
- Floating terminal
- Fuzzy file search (`<Space><Space>`) and grep (`<Space>fg`)
- Persistent theme switching (`<Space>tt`)

At that point you'll be past VSCode feature-parity and can start going deeper
into the Neovim-specific things that have no VSCode equivalent (see the generic
learning plan below).

---

## The Neovim learning curve — what to expect

The biggest difference from VSCode is **modal editing**.

Neovim has modes. You are always in exactly one mode:

| Mode | How to enter | What happens when you type |
|---|---|---|
| **Normal** | `Esc` (always works) | Commands and motions. Default mode. |
| **Insert** | `i`, `a`, `o` | Text is typed into the file |
| **Visual** | `v`, `V`, `Ctrl-v` | Select text |
| **Command** | `:` | Run ex commands like `:colorscheme` or `:w` |

This feels wrong for about a week, then becomes faster than a mouse.

**The five commands you need on day one:**
```
i        enter Insert mode (start typing)
Esc      go back to Normal mode
:w       save the file
:q       quit
:wq      save and quit
```

---

## Learning plan

This is ordered from "zero risk" to "full IDE". Each step builds on the last.
Estimated times assume ~30 min per day of actual usage.

---

### Phase 1 — Get comfortable (Week 1–2)

**Goal:** survive in Neovim without reaching for the mouse or ESC key.

1. **Learn the core motions in Normal mode**

   The most important ones to start:
   ```
   h j k l      ← ↓ ↑ →  (arrow keys also work, but wean off them)
   w / b        jump forward / backward one word
   0 / $        start / end of line
   gg / G       top / bottom of file
   dd           delete (cut) a line
   yy           copy (yank) a line
   p            paste below
   u            undo
   Ctrl-r       redo
   /pattern     search forward, n to jump to next match
   ```
   Spend 10 minutes on `vimtutor` — run it by typing `:Tutor` inside Neovim.

2. **Read `lua/config/options.lua` and change one setting**

   Open it with `:e ~/.config/nvim/lua/config/options.lua`.
   Try changing `vim.opt.tabstop` from its current value and see what happens.
   This is the safest possible customization — you are just changing numbers.

3. **Try the theme picker**

   Press `<Space>tt` in Normal mode. A floating picker appears with all
   installed colorschemes. Arrow keys + Enter to pick. The choice is saved
   permanently. See `lua/themes/README.md` for the full list.

---

### Phase 2 — Add the features you used in VSCode (Week 3–6)

**Goal:** have the core VSCode features available in Neovim.

4. **File explorer** — add `neo-tree.nvim`

   Create `lua/plugins/explorer.lua`:
   ```lua
   return {
     "nvim-neo-tree/neo-tree.nvim",
     dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
     cmd = "Neotree",
     keys = { { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "File Explorer" } },
   }
   ```
   Then `:Lazy sync` to install. Press `<Space>e` to toggle it.
   This is the closest thing to VSCode's sidebar file explorer.

5. **Git gutter + blame** — add `gitsigns.nvim`

   Create `lua/plugins/gitsigns.lua`:
   ```lua
   return {
     "lewis6991/gitsigns.nvim",
     opts = {
       signs = { add = { text = "+" }, change = { text = "~" }, delete = { text = "_" } },
       current_line_blame = false, -- set true to see blame on each line
     },
   }
   ```
   Shows `+` / `~` / `_` in the gutter next to changed lines, just like VSCode.

6. **Status line** — add `lualine.nvim`

   Create `lua/plugins/statusline.lua`:
   ```lua
   return {
     "nvim-lualine/lualine.nvim",
     opts = { options = { theme = "auto" } },
   }
   ```
   Gives you a status bar at the bottom showing mode, file, git branch, diagnostics.

7. **Autocompletion** — add `blink.cmp`

   The LSP is installed but needs a completion UI on top of it.
   Create `lua/plugins/completion.lua` — see `lua/plugins/README.md` for a
   ready-to-paste snippet.

---

### Phase 3 — Go deeper (Month 2)

**Goal:** learn the Neovim-specific workflows that have no VSCode equivalent.

8. **Set up language servers for your languages**

   Run `:Mason` to open the installer. Search for and install:
   - `typescript-language-server` (JS/TS)
   - `gopls` (Go)
   - `lua-language-server` (Lua/Neovim config)
   - `bash-language-server` (Shell scripts)

   See `lsp/README.md` for how to wire each one up.

9. **Learn the snacks.nvim picker** (already installed)

   Press `<Space>` and wait — if which-key is installed you'll see a menu.
   Key bindings to learn:
   ```
   :lua Snacks.picker.files()        ← fuzzy-find files (like Ctrl-P in VSCode)
   :lua Snacks.picker.grep()         ← live grep across project (like Ctrl-Shift-F)
   :lua Snacks.picker.buffers()      ← switch between open files
   ```
   Consider adding these to `lua/config/keymaps.lua`.

10. **Formatting and linting**

    Add `conform.nvim` for formatting (like Prettier) and `nvim-lint` for
    linting (like ESLint). Both go in `lua/plugins/`. See `lua/plugins/README.md`.

11. **Integrated terminal** — add `toggleterm.nvim`

    Create `lua/plugins/terminal.lua`:
    ```lua
    return {
      "akinsho/toggleterm.nvim",
      version = "*",
      opts = { open_mapping = [[<C-\>]], direction = "float" },
    }
    ```
    `Ctrl-\` toggles a floating terminal. Familiar if you used VSCode's terminal.

---

### Phase 4 — Power features (When you feel at home)

12. **Debugging (DAP)** — `nvim-dap` + `nvim-dap-ui`

    This replicates VSCode's debugger with breakpoints, step-through, variable
    inspection. It requires per-language adapter setup. Add it when you are
    comfortable with the rest of the config.

13. **Write your own keymaps**

    Once you know what actions you repeat, open `lua/config/keymaps.lua` and
    add bindings. Example:
    ```lua
    -- Format the current file
    set("n", "<leader>f", function() require("conform").format() end, { desc = "Format file" })
    ```

14. **Learn Lua basics for config editing**

    You don't need to be a Lua programmer to configure Neovim, but knowing the
    basics helps. Key things: tables `{}`, functions `function() end`, the
    colon method call syntax `vim.opt.number = true`. The Lua reference at
    https://www.lua.org/pil/1.html is short and readable.

---

## Quick reference — common commands

```
:Lazy          open the plugin manager UI
:Lazy sync     install / update / clean plugins
:Mason         open the LSP/tool installer
:Tutor         interactive Neovim tutorial (start here)
:checkhealth   diagnose config and plugin issues
:help <topic>  built-in documentation (e.g. :help options)
<Space>tt      theme picker (persistent)
```

---

## Files you should NOT edit

- `lazy-lock.json` — managed by lazy.nvim automatically
- Any file inside `~/.local/share/nvim/lazy/` — those are plugin source files
