-- Synthweave theme (https://github.com/samharju/synthweave.nvim)
-- A clean SynthWave '84 port that intentionally ships WITHOUT a glow effect.
-- The author designed it glow-free by choice; there is no glow configuration
-- option. If you want glow, use fluoromachine.nvim instead.
--
-- Available colorscheme names (usable via :colorscheme):
--   synthweave              → opaque background version
--   synthweave-transparent  → transparent background version
--
-- NOTE: This theme relies heavily on treesitter captures for highlight groups.
-- Languages without treesitter parsers installed may look plain.
--
-- To make this the default, uncomment synthweave.load() below and comment out
-- the colorscheme call in whichever theme file is currently active.

return {
  {
    "samharju/synthweave.nvim",

    -- lazy = false: load eagerly so :colorscheme synthweave is always available.
    lazy = false,

    -- priority = 1000: required for colorscheme plugins to initialize before
    -- other plugins that depend on highlight groups.
    priority = 1000,

    config = function()
      local synthweave = require("synthweave")

      synthweave.setup({
        -- transparent = true uses the synthweave-transparent colorscheme variant.
        -- You can also switch to it at runtime via :colorscheme synthweave-transparent
        transparent = false,

        -- overrides: modify specific highlight groups after the theme is applied.
        -- Example: Identifier = { fg = "#f22f52" }
        overrides = {},

        -- palette: override the base color tokens.
        -- See synthweave/palette.lua in the plugin source for all available keys.
        palette = {},
      })

      -- synthweave.load() applies the colorscheme using the setup() config above.
      -- Equivalent to: vim.cmd.colorscheme("synthweave")
      --
      -- synthweave.load()
      -- ↑ Uncomment to make synthweave the active default theme.
      --   Comment out the colorscheme call in the currently active theme file.
    end,
  },
}
