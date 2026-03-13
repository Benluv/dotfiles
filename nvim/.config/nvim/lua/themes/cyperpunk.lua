-- Cyberpunk theme (https://github.com/taigrr/cyberpunk.nvim)
--
-- Colorscheme name: cyberpunk
-- To activate at runtime: :colorscheme cyberpunk
--
-- This plugin is installed and available but NOT set as the default.
-- To make it the default, uncomment vim.cmd.colorscheme below and remove
-- the call from whichever theme file currently contains it.

return {
  "taigrr/cyberpunk.nvim",

  -- lazy = false keeps the colorscheme immediately available so that
  -- :colorscheme cyberpunk works from the command line without a trigger.
  lazy = false,

  -- priority = 1000 ensures this loads before other plugins if it ever
  -- becomes the active theme. Safe to keep even when not the default.
  priority = 1000,

  opts = {
    transparent = false,     -- set true for a transparent background
    italic_comments = false, -- italicize comments
    italic_keywords = false, -- italicize keywords
    bold_functions = false,  -- bold function names
    bold_keywords = true,    -- bold keywords
    overrides = {},          -- override specific highlight groups
  },

  -- config = function(_, opts)
  --   require("cyberpunk").setup(opts)
  --   vim.cmd.colorscheme("cyberpunk")
  --   -- ↑ Uncomment the two lines above (and the closing end below) to
  --   --   switch to cyberpunk as the default colorscheme.
  -- end,
}
