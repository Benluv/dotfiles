-- [[ lua/plugins/copilot.lua ]]
-- GitHub Copilot Enterprise inline ghost text.
-- Starts DISABLED by default. Toggle with <leader>ai.
-- On first use, run :Copilot auth to authenticate against your GHE instance.
return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      -- Point at the Etraid GitHub Enterprise instance
      copilot_node_command = "node",
      server_opts_overrides = {
        settings = {
          advanced = {
            authProvider = "github-enterprise",
          },
        },
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,   -- show ghost text as you type
        hide_during_completion = true,
        debounce = 75,
        keymap = {
          accept        = "<C-j>", -- changed from <Tab> to prevent conflict with standard indentation
          accept_word   = "<M-w>",
          accept_line   = "<M-l>",
          next          = "<M-]>",
          prev          = "<M-[>",
          dismiss       = "<C-]>",
        },
      },
      panel = { enabled = false }, -- ghost text only, no popup panel
      filetypes = {
        ["*"] = true,   -- enable for all filetypes by default
      },
    })

    -- Start disabled; ai-toggle.lua controls activation
    require("copilot.suggestion").toggle_auto_trigger()
    vim.g.copilot_active = false
  end,
}
