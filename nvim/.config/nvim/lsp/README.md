# `lsp/` — Per-server LSP configuration files

This directory holds per-language-server configuration files used by
Neovim 0.11's native LSP system (`vim.lsp.enable()`).

---

## How it works

In `lua/plugins/lsp.lua`, servers are enabled with:
```lua
vim.lsp.enable("lua_ls")
```

When Neovim enables a server, it automatically looks for a matching file in
the `lsp/` directory at the root of your config. So `vim.lsp.enable("lua_ls")`
reads `lsp/lua_ls.lua` for its settings. No `require()` needed — Neovim
handles the lookup automatically.

This is a Neovim 0.11 convention. Earlier configs put all server settings
inside `nvim-lspconfig`'s setup call; the `lsp/` directory approach keeps
each server's config isolated and easier to manage.

---

## Currently configured servers

### `lua_ls.lua` — Lua language server

Used for your Neovim config files themselves. Settings disable some
aggressive auto-complete behaviors that are noisy when writing config code:
- No postfix completions (`''`, `""`, `[]`)
- No auto-`require()` insertion
- LuaJIT runtime (what Neovim uses)

---

## Adding a new language server

### Step 1 — Install the server via Mason

Open Neovim and run:
```
:Mason
```
Search for the server name, press `i` to install.

Or install directly:
```
:MasonInstall <server-name>
```

### Step 2 — Add the server name to `lsp.lua`

Open `lua/plugins/lsp.lua`. Find the two places where servers are listed
and add the new name:

```lua
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "pyright", "ts_ls" },  -- add here
})

vim.iter({ "lua_ls", "pyright", "ts_ls" }):each(function(server)  -- and here
  vim.lsp.enable(server)
end)
```

### Step 3 — Create a config file in `lsp/` (optional but recommended)

Create `lsp/<server-name>.lua` returning a table with any server-specific
settings. If you don't need custom settings, you can skip this step.

---

## Server names and config files for your languages

### JavaScript / TypeScript — `ts_ls` ← Start here

Install: `:MasonInstall typescript-language-server`

Add `"ts_ls"` to the two lists in `lua/plugins/lsp.lua` (see Step 2 in Adding
a new language server above).

Create `lsp/ts_ls.lua`:
```lua
return {
  -- Tell the server about common JS/TS project configs
  init_options = {
    preferences = {
      includeInlayParameterNameHints = "all",
      includeInlayFunctionLikeReturnTypeHints = true,
    },
  },
}
```

After restarting Neovim, open any `.js` or `.ts` file and you should see
completions, errors, and `gd` (go-to-definition) working immediately.

---

### HTML — `html`

Install: `:MasonInstall html-lsp`

Add `"html"` to the server lists in `lua/plugins/lsp.lua`.

No extra config file needed — the defaults work well. If you want to create
one for custom settings:
```lua
-- lsp/html.lua
return {
  filetypes = { "html" },
}
```

---

### CSS / SCSS / Less — `cssls`

Install: `:MasonInstall css-lsp`

Add `"cssls"` to the server lists in `lua/plugins/lsp.lua`.

No extra config file needed.

---

### Bash / Shell — `bashls`

Install: `:MasonInstall bash-language-server`

Add `"bashls"` to the server lists in `lua/plugins/lsp.lua`.

Create `lsp/bashls.lua`:
```lua
return {
  -- Bash language server works out of the box with no extra config
  filetypes = { "sh", "bash" },
}
```

---

### Lua (already configured) — `lua_ls`

Config file: `lsp/lua_ls.lua` (already exists).
This handles your Neovim config files themselves — go-to-definition works
inside `init.lua` and all `lua/` files.

---

### Go — `gopls` (for when you start learning Go)

Install: `:MasonInstall gopls`

Create `lsp/gopls.lua`:
```lua
return {
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,  -- warn about unused function parameters
        shadow = true,        -- warn about shadowed variables
      },
      staticcheck = true,     -- run staticcheck linter via gopls
      gofumpt = true,         -- use gofumpt formatter (stricter than gofmt)
    },
  },
}
```

---

### Python — `pyright` (already installed)

Already in `lua/plugins/lsp.lua`. No extra steps needed.

---

## LSP keybindings (active when a server attaches)

These are set in `lua/plugins/lsp.lua` inside the `LspAttach` autocmd:

```
gd           Go to definition
K            Hover docs (show type / documentation for symbol under cursor)
<leader>rn   Rename symbol across the file
```

**Useful bindings to add** (in the `LspAttach` callback in `lsp.lua`):
```lua
vim.keymap.set("n", "gr",          vim.lsp.buf.references,     opts)  -- find all usages
vim.keymap.set("n", "<leader>ca",  vim.lsp.buf.code_action,    opts)  -- code actions (like lightbulb in VSCode)
vim.keymap.set("n", "gi",          vim.lsp.buf.implementation, opts)  -- go to implementation
vim.keymap.set("n", "<leader>d",   vim.diagnostic.open_float,  opts)  -- show diagnostic detail
vim.keymap.set("n", "]d",          function() vim.diagnostic.jump({ count = 1  }) end, opts)
vim.keymap.set("n", "[d",          function() vim.diagnostic.jump({ count = -1 }) end, opts)
```

---

## Checking what is attached

To see which servers are running on the current file:
```
:checkhealth lsp
:lua print(vim.inspect(vim.lsp.get_clients()))
```

---

## Diagnostics — the coloured underlines and gutter icons

LSP servers send **diagnostics** (errors, warnings, hints) which Neovim
displays as:
- Coloured underlines in the buffer
- Icons in the sign column (`E`, `W`, `I`, `H` by default)
- Virtual text at the end of the line

To change the diagnostic icons to something nicer, add this to
`lua/config/options.lua`:
```lua
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN]  = " ",
      [vim.diagnostic.severity.INFO]  = " ",
      [vim.diagnostic.severity.HINT]  = "󰌵 ",
    },
  },
  virtual_text = true,      -- show message at end of line
  underline = true,
  update_in_insert = false, -- don't update diagnostics while typing
})
```

(Requires a Nerd Font to be installed and set as your terminal font.)
