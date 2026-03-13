-- Tokyo Night theme (https://github.com/folke/tokyonight.nvim)
--
-- Available styles (all usable via :colorscheme):
--   tokyonight         → defaults to the style set in setup() below
--   tokyonight-storm   → dark blue/grey, slightly lighter than night
--   tokyonight-moon    → darker blue/purple variant
--   tokyonight-night   → darkest variant
--   tokyonight-day     → light theme
--
-- To switch at runtime: :colorscheme tokyonight-moon  (no restart needed)
--
-- IMPORTANT: setup() MUST be called before vim.cmd.colorscheme, otherwise
-- the options defined here won't take effect.

return {
  {
    "folke/tokyonight.nvim",

    -- lazy = false ensures the plugin is loaded at startup (not deferred).
    -- This is required for colorscheme plugins so the theme is available
    -- before any UI elements are drawn.
    lazy = false,

    -- priority = 1000 makes lazy.nvim load this plugin before all others.
    -- Without this, other plugins (e.g. statuslines) may render before the
    -- theme is applied, causing a flash of wrong colors.
    priority = 1000,

    config = function()
      require("tokyonight").setup({
        -- The default style applied when you run :colorscheme tokyonight
        -- (without a suffix). Individual variants are always available via
        -- :colorscheme tokyonight-<style> regardless of this value.
        style = "storm",

        -- Used when vim.o.background = "light"
        light_style = "day",

        -- Set true to make the background transparent (useful in terminals
        -- with their own background color set).
        transparent = false,

        -- Pass ANSI terminal colors through so your terminal emulator
        -- matches the editor palette.
        terminal_colors = true,

        styles = {
          -- Syntax group styles — any valid attr-list for :help nvim_set_hl
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},

          -- Background style for sidebars (e.g. NvimTree, Neogit panels).
          -- Options: "dark" | "transparent" | "normal"
          sidebars = "dark",

          -- Background style for floating windows (e.g. LSP hover docs).
          floats = "dark",
        },

        -- Cache the compiled theme for faster startups. Invalidated
        -- automatically when the config changes.
        cache = true,
      })

      -- Apply the default style defined in setup() above.
      -- The other variants (storm, moon, night, day) remain available as
      -- standalone colorscheme names and can be switched at any time with
      -- :colorscheme tokyonight-<style>
      vim.cmd.colorscheme("tokyonight")
    end,
  },
}
