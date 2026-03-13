# `lua/plugins/` — Plugin specifications

Every `.lua` file in this directory is automatically discovered by lazy.nvim
and treated as a plugin specification. You never need to list them in `init.lua`.

To add a new plugin: create a new `.lua` file here, return a table describing
the plugin, then run `:Lazy sync` to install it.

---

## What belongs here vs `lua/themes/`

| `lua/plugins/` | `lua/themes/` |
|---|---|
| Tools, features, language support | Colorschemes only |
| LSP, search, git, completion, explorer | tokyonight, catppuccin, etc. |

The distinction is organisational. Both folders are loaded identically.

---

## Currently installed plugins

### `lsp.lua` — Language Server Protocol

**VSCode equivalent:** IntelliSense engine + extension language support.

LSP is a standard protocol that separates the editor from the language
intelligence. The language server runs as a separate process; Neovim talks
to it. This means the same server (`gopls`) works in Neovim, VSCode, Emacs, etc.

**What is installed:**
- `nvim-lspconfig` — the Neovim LSP client configuration layer
- `mason.nvim` — a package manager for LSP servers, formatters, and linters
- `mason-lspconfig.nvim` — bridges mason and lspconfig so servers installed
  via mason are automatically configured

**Currently active servers:** `lua_ls` (Lua), `pyright` (Python)

**Key bindings added by this plugin (when a server is attached):**
```
gd           Go to definition (like F12 in VSCode)
K            Hover documentation (like hovering over a symbol in VSCode)
<leader>rn   Rename symbol (like F2 in VSCode)
```

**To add more servers:** see `lsp/README.md`.

**How native completion works:**
This config uses Neovim 0.11's **built-in completion** (`vim.lsp.completion`).
No extra completion plugin is required. When a language server is attached,
completions appear automatically as you type. Press `Tab` or `Ctrl-n` / `Ctrl-p`
to navigate the popup, `Enter` to confirm.

> If you want a richer completion UI (icons, documentation preview,
> snippet support), add `blink.cmp` — see the snippet below.

---

### `snacks.lua` — Picker, dashboard, and notifications

**VSCode equivalent:** Quick Open (`Ctrl-P`), global search (`Ctrl-Shift-F`),
command palette, notification toasts.

snacks.nvim is a collection of small quality-of-life tools bundled together.
The ones enabled here:

- **picker** — fuzzy finder for files, grep, buffers, help pages
- **dashboard** — the startup screen shown when you open Neovim with no file
- **notifier** — styled floating notifications instead of the default command-line messages

**Key bindings (already active):**
```
<Space><Space>   Smart file finder (searches recent files + git files)
<Space>ff        Find files by name (fuzzy)
<Space>fg        Live grep — search text across the whole project
<Space>fb        Switch between open buffers (like Ctrl-Tab in VSCode)
<Space>fh        Search Neovim's built-in help documentation
```

---

### `treesitter.lua` — Syntax highlighting

**VSCode equivalent:** Semantic syntax highlighting provided by language extensions.

Treesitter parses your code into an actual syntax tree rather than using
regex patterns. This produces significantly more accurate highlighting,
especially for nested structures, template literals, JSX, etc.

It also powers: code folding, indentation, text objects (`daf` to delete a
function, `vic` to select inside a class, etc.).

---

### `opencode.lua` — AI assistant

An AI coding assistant integrated directly into Neovim. Similar to Copilot
Chat or Cursor's AI panel.

---

## What to add next

The order below matches your personal roadmap (see the root `README.md`).
Each entry is a self-contained file you create in this folder.

---

### 1. Status bar — `lualine.nvim`

A configurable status bar showing: mode, filename, git branch, LSP diagnostics,
file type, cursor position. The `"auto"` theme picks colours that match
whichever colorscheme is active.

Create `lua/plugins/statusline.lua`:
```lua
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      theme = "auto",   -- picks a theme matching your active colorscheme
      component_separators = "|",
      section_separators = "",
    },
  },
}
```

> `nvim-web-devicons` provides file-type icons in the statusline. These
> icons require a Nerd Font — see the root `README.md` on how to install one.

---

### 2. File explorer — `neo-tree.nvim`

The closest thing to VSCode's sidebar explorer.

Create `lua/plugins/explorer.lua`:
```lua
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  lazy = false,
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "File Explorer" },
  },
  opts = {
    window = { width = 30 },
    filesystem = {
      filtered_items = { hide_dotfiles = false },  -- show hidden files
    },
  },
}
```

Install: `:Lazy sync`, then press `<Space>e`.

---

### 3. Git gutter signs — `gitsigns.nvim`

Shows `+` / `~` / `_` in the gutter next to added, changed, and deleted
lines — identical to the VSCode git gutter.

Create `lua/plugins/gitsigns.lua`:
```lua
return {
  "lewis6991/gitsigns.nvim",
  opts = {
    signs = {
      add          = { text = "+" },
      change       = { text = "~" },
      delete       = { text = "_" },
      topdelete    = { text = "‾" },
      changedelete = { text = "~" },
    },
    -- Inline git blame on the current line (toggle with <leader>gb)
    current_line_blame = false,
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local set = vim.keymap.set
      set("n", "]c", gs.next_hunk, { buffer = bufnr, desc = "Next git hunk" })
      set("n", "[c", gs.prev_hunk, { buffer = bufnr, desc = "Previous git hunk" })
      set("n", "<leader>hs", gs.stage_hunk, { buffer = bufnr, desc = "Stage hunk" })
      set("n", "<leader>hr", gs.reset_hunk, { buffer = bufnr, desc = "Reset hunk" })
      set("n", "<leader>gb", gs.toggle_current_line_blame, { buffer = bufnr, desc = "Toggle git blame" })
    end,
  },
}
```

---

### 4. Richer completion UI — `blink.cmp`

The native 0.11 completion works but has no icons, no documentation preview,
and no snippet support. blink.cmp adds all of that.

Create `lua/plugins/completion.lua`:
```lua
return {
  "saghen/blink.cmp",
  version = "*",
  opts = {
    keymap = { preset = "default" },  -- Tab/Ctrl-n/Ctrl-p to navigate
    appearance = { use_nvim_cmp_as_default = true },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
    completion = { documentation = { auto_show = true } },
  },
}
```

> **Important:** once blink.cmp is installed, open `lua/plugins/lsp.lua` and
> comment out or delete the `vim.lsp.completion.enable(...)` line inside the
> `LspAttach` callback. The two systems conflict — blink.cmp replaces the native UI.

---

### 5. Formatting — `conform.nvim`

Runs a formatter on your file, either on demand or automatically on save.
For your stack, this means Prettier for JS/TS/HTML/CSS and shfmt for shell.

Create `lua/plugins/formatting.lua`:
```lua
return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      javascript  = { "prettier" },
      typescript  = { "prettier" },
      html        = { "prettier" },
      css         = { "prettier" },
      scss        = { "prettier" },
      json        = { "prettier" },
      markdown    = { "prettier" },
      lua         = { "stylua" },
      sh          = { "shfmt" },
      bash        = { "shfmt" },
    },
    -- Auto-format when saving. Comment this out if you prefer manual formatting.
    format_on_save = { timeout_ms = 1000, lsp_fallback = true },
  },
  keys = {
    { "<leader>f", function() require("conform").format() end, desc = "Format file" },
  },
}
```

Install the formatters via Mason:
```
:MasonInstall prettier stylua shfmt
```

---

### 6. Floating terminal — `toggleterm.nvim`

A managed terminal that floats over your editor. Opens your zsh + p10k shell.
`Ctrl-\` to toggle.

Create `lua/plugins/terminal.lua`:
```lua
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
    open_mapping = [[<C-\>]],     -- Ctrl-\ to toggle
    direction = "float",           -- "float", "horizontal", or "vertical"
    float_opts = { border = "curved" },
  },
}
```

---

### 7. Debugging — `nvim-dap` + `nvim-dap-ui`

Replicates VSCode's debugger: breakpoints, step-through, variable inspection.
This is more involved to set up because each language needs its own debug
adapter. Add this after you're comfortable with the rest.

Key plugins:
- `mfussenegger/nvim-dap` — the core DAP client
- `rcarriga/nvim-dap-ui` — the UI panels (variables, call stack, breakpoints)
- `jay-babu/mason-nvim-dap.nvim` — installs debug adapters via mason

---

## How a plugin spec works

```lua
return {
  "author/plugin-name",   -- GitHub repo (short form)

  lazy = false,           -- false = load at startup, true = load on demand
  priority = 1000,        -- higher loads first (only matters for colorschemes usually)
  event = "BufReadPre",   -- load when this event fires (lazy loading)
  cmd = "SomeCommand",    -- load when this command is run
  ft = "lua",             -- load only for this filetype
  keys = { ... },         -- load when these keys are pressed, also registers the mapping

  dependencies = { ... }, -- other plugins that must load first

  opts = { ... },         -- passed to require("plugin").setup(opts) automatically
  config = function()     -- custom setup logic (use instead of opts if you need code)
    require("plugin").setup({ ... })
  end,
}
```

For most plugins, `opts = {}` is all you need. Use `config = function()` only
when you need to run Lua code beyond just calling setup().
