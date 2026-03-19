-- [[ lua/config/options.lua ]]
-- See :help vim.opt
local opt = vim.opt

opt.clipboard:append("unnamedplus")
opt.hlsearch = true

opt.number = true             -- Show line numbers
opt.relativenumber = true     -- Relative numbers help with vertical jumping
opt.mouse = 'a'               -- Enable mouse support
opt.showmode = false          -- Don't show mode (e.g. -- INSERT --) because statusline does it
opt.breakindent = true        -- Wrapped lines keep indentation
opt.undofile = true           -- Save undo history across sessions
opt.ignorecase = true         -- Case-insensitive searching...
opt.smartcase = true          -- ...unless \C or capital in search
opt.signcolumn = 'yes'        -- Always show the sign column (prevents "flicker")
opt.updatetime = 250          -- Faster completion and diagnostic display
opt.timeoutlen = 600          -- Give more time to press the leader key combo (was 300)
opt.splitright = true         -- Put new windows to the right
opt.splitbelow = true         -- Put new windows below
opt.cursorline = true         -- Highlight the current line
opt.scrolloff = 10            -- Keep 10 lines above/below cursor
opt.smoothscroll = true       -- v0.11 feature: pixel-perfect scrolling
opt.tabstop = 2               -- Number of spaces a <Tab> counts for visually
opt.shiftwidth = 2            -- Number of spaces used for each indentation step (>> / <<)
opt.expandtab = true          -- Insert spaces instead of a tab character

-- Diagnostics (inline warnings/errors)
vim.diagnostic.config({
  virtual_text = true, -- Show text at the end of the line
  signs = true,        -- Show sign in the sign column
  underline = true,    -- Underline the diagnostic code
  update_in_insert = false,
})

-- 120-Character line limit marker
opt.colorcolumn = "120"
