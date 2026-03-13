-- [[ lua/plugins/lsp.lua ]]
-- Website: https://github.com/neovim/nvim-lspconfig
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright" },
      })

      -- Modern v0.11 LSP Enablement loop
      -- Uses vim.iter (modern functional iterator)
      vim.iter({ "lua_ls", "pyright" }):each(function(server)
        vim.lsp.enable(server)
      end)

      -- Global LspAttach logic for keymaps
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local opts = { buffer = args.buf }

          -- v0.11 Native Completion (No extra plugins required!)
          if client and client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = false})
          end

          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        end,
      })
    end,
  },
}
