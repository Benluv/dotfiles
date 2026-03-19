return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    -- Ensure mason's bin dir is on PATH so eslint_d is always found
    -- even if the user's shell PATH doesn't include it.
    local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
    if not vim.env.PATH:find(mason_bin, 1, true) then
      vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
    end

    -- Extend the built-in eslint_d linter to always use the etraid shared config.
    -- cwd is set to the buffer's directory so eslint's flat-config basePath
    -- matches the project tree and files aren't reported as "outside base path".
    local eslint = lint.linters.eslint_d
    local config_path = vim.fn.expand("~/.config/etraid_linter_formatter/eslint.config.mjs")

    eslint.args = {
      "-c", config_path,
      "--format", "json",
      "--stdin",
      "--stdin-filename",
      function() return vim.api.nvim_buf_get_name(0) end,
    }

    -- Run eslint_d from the current buffer's directory so flat-config
    -- treats the project files as within the base path.
    eslint.cwd = function()
      return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
    end

    lint.linters_by_ft = {
      javascript      = { "eslint_d" },
      typescript      = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      svelte          = { "eslint_d" },
    }

    -- Trigger linting on these events.
    -- TextChanged covers edits in normal mode, TextChangedI covers insert mode edits.
    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
    vim.api.nvim_create_autocmd({
      "BufEnter", "BufWritePost", "InsertLeave", "TextChanged",
    }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    vim.keymap.set("n", "<leader>l", function()
      lint.try_lint()
    end, { desc = "Trigger linting for current file" })
  end,
}
