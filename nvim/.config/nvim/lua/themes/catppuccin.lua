-- Catppuccin theme (https://github.com/catppuccin/nvim)
-- Soothing pastel theme with 4 flavours. Originated the entire Catppuccin
-- project and remains its most feature-complete port.
--
-- Available colorscheme names (usable via :colorscheme):
--   catppuccin             → uses the flavour set in setup() below (mocha)
--   catppuccin-latte       → light, warm pastel (the only light flavour)
--   catppuccin-frappe      → cool medium-dark
--   catppuccin-macchiato   → deeper, more saturated dark
--   catppuccin-mocha       → darkest, richest variant
--
-- All four names are always available regardless of the default flavour.
-- Switch at runtime: :colorscheme catppuccin-macchiato
--
-- IMPORTANT: setup() MUST be called before vim.cmd.colorscheme.

return {
  {
    "catppuccin/nvim",

    -- lazy.nvim requires the plugin to be named differently from its repo
    -- path because "nvim" would conflict. The `name` key sets the internal
    -- plugin identifier used by lazy and for require().
    name = "catppuccin",

    -- lazy = false + priority = 1000: standard requirements for any colorscheme
    -- plugin (load eagerly, before all other plugins).
    lazy = false,
    priority = 1000,

    config = function()
      require("catppuccin").setup({
        -- The flavour applied when :colorscheme catppuccin (no suffix) is used.
        -- Options: "latte" | "frappe" | "macchiato" | "mocha"
        flavour = "mocha",

        -- Which flavour to use when vim.o.background == "light"
        background = {
          light = "latte",
          dark = "mocha",
        },

        -- Remove the background fill (useful for terminals with custom backgrounds)
        transparent_background = false,

        -- Pass ANSI terminal palette colors through so the terminal emulator
        -- matches the editor colors (e.g. in :terminal buffers)
        term_colors = true,

        -- Dim inactive windows slightly
        dim_inactive = {
          enabled = false,
          shade = "dark",
          percentage = 0.15,
        },

        -- Force-disable text decoration globally if needed
        no_italic = false,
        no_bold = false,
        no_underline = false,

        -- Syntax group styles
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          keywords = {},
          functions = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          types = {},
          operators = {},
        },

        -- auto_integrations: catppuccin will detect installed plugins and
        -- automatically enable highlight group support for them.
        -- Set to false and use the integrations table below for manual control.
        auto_integrations = true,

        -- Explicit integration overrides (takes effect even with auto_integrations)
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          telescope = { enabled = true },
          -- Add or disable integrations here as needed.
          -- Full list: https://github.com/catppuccin/nvim#integrations
        },
      })

      -- vim.cmd.colorscheme("catppuccin")
      -- ↑ Uncomment to make catppuccin (mocha) the active default theme.
      --   Comment out the colorscheme call in the currently active theme file.
      --   You can also use "catppuccin-latte", "catppuccin-frappe", etc.
    end,
  },
}
