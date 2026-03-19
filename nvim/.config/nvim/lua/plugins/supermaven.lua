-- [[ lua/plugins/supermaven.lua ]]
-- Supermaven free-tier inline ghost text.
-- Starts ENABLED by default. Toggle with <leader>ai.
-- No account needed beyond a one-time signup at https://supermaven.com
return {
	"supermaven-inc/supermaven-nvim",
	event = "InsertEnter",
	config = function()
		require("supermaven-nvim").setup({
			keymaps = {
				accept_suggestion = "<C-j>",
				clear_suggestion = "<C-]>",
				accept_word = "<M-w>",
			},
			ignore_filetypes = {},
			color = {
				suggestion_color = "#6c7086", -- muted ghost text colour (works on dark themes)
				cterm = 244,
			},
			log_level = "off",
			disable_inline_completion = false,
			disable_keymaps = false,
		})

		vim.g.supermaven_active = true
	end,
}
