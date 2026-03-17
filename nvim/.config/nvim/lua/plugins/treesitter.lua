-- [[ lua/plugins/treesitter.lua ]]
-- Website: https://github.com/nvim-treesitter/nvim-treesitter
return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      -- v0.11+ FIX: We check if the module exists before calling it.
      -- If it's missing, it's because Treesitter now handles config internally.
      local status, configs = pcall(require, "nvim-treesitter.configs")
      if not status then
          return
      end

      configs.setup({
        ensure_installed = { "lua", "python", "javascript", "typescript", "jsx", "tsx", "vimdoc", "vim", "markdown", "markdown_inline" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
}
