-- [[ lua/config/theme.lua ]]
-- Persistent theme switcher.
--
-- HOW IT WORKS
-- ─────────────
-- 1. On startup, this module reads ~/.local/share/nvim/theme (or equivalent)
--    to find the last-used colorscheme name.
-- 2. If a saved theme exists it is applied instead of the hardcoded default
--    in whichever themes/*.lua has vim.cmd.colorscheme uncommented.
-- 3. A ColorScheme autocommand fires every time :colorscheme <name> is used
--    (manually or programmatically) and writes the new name to the file.
--    This makes persistence fully automatic — no extra command needed.
--
-- HOW TO USE
-- ─────────────
-- • Switch theme at runtime:     :colorscheme tokyonight-moon
--                                :colorscheme catppuccin-macchiato
--                                :colorscheme fluoromachine
--   The new theme is saved immediately and will be restored on next startup.
--
-- • Key mapping <leader>tt opens a picker with all available themes.
--   Press Enter to apply and persist the selection.
--   (wired in lua/config/keymaps.lua)
--
-- AVAILABLE THEMES (all installed via lua/themes/)
-- ─────────────────────────────────────────────────
-- Tokyo Night:   tokyonight  tokyonight-storm  tokyonight-moon
--                tokyonight-night  tokyonight-day
-- Fluoromachine: fluoromachine  retrowave  delta
-- Catppuccin:    catppuccin  catppuccin-latte  catppuccin-frappe
--                catppuccin-macchiato  catppuccin-mocha
-- Synthweave:    synthweave  synthweave-transparent
-- Cyberpunk:     cyberpunk

local M = {}

-- Path to the persistence file. stdpath("data") is ~/.local/share/nvim on Linux.
local theme_file = vim.fn.stdpath("data") .. "/theme"

-- All colorscheme names exposed by the installed theme plugins.
-- Add new names here whenever you install a new theme.
M.themes = {
  -- Tokyo Night
  "tokyonight",
  "tokyonight-storm",
  "tokyonight-moon",
  "tokyonight-night",
  "tokyonight-day",
  -- Fluoromachine (sub-palettes share the same :colorscheme name)
  "fluoromachine",
  "retrowave",
  "delta",
  -- Catppuccin
  "catppuccin",
  "catppuccin-latte",
  "catppuccin-frappe",
  "catppuccin-macchiato",
  "catppuccin-mocha",
  -- Synthweave
  "synthweave",
  "synthweave-transparent",
  -- Cyberpunk
  "cyberpunk",
}

-- save() writes a colorscheme name to the persistence file.
-- Called automatically by the ColorScheme autocmd below.
function M.save(name)
  local f = io.open(theme_file, "w")
  if f then
    f:write(name)
    f:close()
  end
end

-- load() reads the saved colorscheme name and applies it.
-- Returns true if a saved theme was found and applied, false otherwise.
function M.load()
  local f = io.open(theme_file, "r")
  if not f then return false end
  local name = f:read("*l")
  f:close()
  if name and name ~= "" then
    -- pcall guards against the colorscheme not being installed yet
    -- (e.g. first run before lazy.nvim has synced plugins).
    local ok, err = pcall(vim.cmd.colorscheme, name)
    if not ok then
      vim.notify(
        "[theme] Could not restore '" .. name .. "': " .. err .. "\nFalling back to default.",
        vim.log.levels.WARN
      )
      return false
    end
    return true
  end
  return false
end

-- pick() opens a simple vim.ui.select picker with all known themes.
-- Selecting one applies it immediately and persists the choice.
function M.pick()
  vim.ui.select(M.themes, {
    prompt = "Select theme:",
    -- Show a live preview as the cursor moves through the list.
    -- vim.ui.select does not natively support previews, but snacks.nvim
    -- (already in your config) will upgrade this to a nice floating picker.
  }, function(choice)
    if choice then
      local ok, err = pcall(vim.cmd.colorscheme, choice)
      if not ok then
        vim.notify("[theme] Could not apply '" .. choice .. "': " .. err, vim.log.levels.ERROR)
      end
      -- The ColorScheme autocmd below handles persistence automatically.
    end
  end)
end

-- Set up the autocmd that persists any colorscheme change, including those
-- triggered by :colorscheme from the command line.
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("ThemePersist", { clear = true }),
  callback = function(ev)
    -- ev.match is the name passed to :colorscheme
    M.save(ev.match)
  end,
  desc = "Persist colorscheme selection to disk",
})

-- Apply the saved theme at startup. This runs after all plugins are loaded
-- (because this file is required from keymaps.lua which is called before
-- lazy.setup, so we defer to VimEnter to ensure plugins are ready).
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("ThemeRestore", { clear = true }),
  once = true,
  callback = function()
    M.load()
  end,
  desc = "Restore last-used colorscheme on startup",
})

return M
