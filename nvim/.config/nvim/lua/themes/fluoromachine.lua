-- Fluoromachine theme (https://github.com/maxmx03/fluoromachine.nvim)
-- A fork of Synthwave84 — neon-drenched sci-fi aesthetic with optional glow.
--
-- Available colorscheme names (usable via :colorscheme):
--   fluoromachine   → neon cyberpunk palette (default sub-theme)
--   retrowave       → retro synthwave variant
--   delta           → softer, more muted variant
--
-- NOTE: The `theme` key inside setup() controls which *internal sub-palette*
-- fluoromachine uses. It is separate from the :colorscheme name, which is
-- always "fluoromachine" regardless of the sub-palette chosen.
--
-- To make this the default, uncomment vim.cmd.colorscheme below and
-- comment out the equivalent line in whichever theme file is currently active.

return {
  {
    "maxmx03/fluoromachine.nvim",

    -- lazy = false: load eagerly at startup so :colorscheme fluoromachine
    -- is always available without a lazy-load trigger.
    lazy = false,

    -- priority = 1000: ensures this is initialized before other plugins,
    -- required for any colorscheme plugin.
    priority = 1000,

    config = function()
      local fm = require("fluoromachine")

      fm.setup({
        -- glow = true enables the neon bloom/glow effect on syntax tokens.
        -- This works via custom highlight overrides applied on top of the
        -- base palette — it requires true-color terminal support.
        glow = true,

        -- Controls which sub-palette is used internally.
        -- Options: 'fluoromachine' | 'retrowave' | 'delta'
        theme = "fluoromachine",

        -- transparent = true removes the background fill so your terminal's
        -- own background shows through.
        transparent = true,

        -- Syntax style overrides (all optional)
        styles = {
          comments = { italic = true },
          functions = {},
          variables = {},
          keywords = { italic = true },
        },
      })

      -- vim.cmd.colorscheme("fluoromachine")
      -- ↑ Uncomment to make fluoromachine the active default theme.
      --   Comment out the colorscheme call in the currently active theme file.
    end,
  },
}
