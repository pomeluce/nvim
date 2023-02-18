local null_ls_status_ok, null_ls = pcall(require, 'null-ls')
if not null_ls_status_ok then
  vim.notify('null-ls 未找到')
  return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics
local code_actions = null_ls.builtins.code_actions

null_ls.setup {
  debug = false,
  sources = {
    -- prettier 格式化配置
    formatting.prettierd.with {
      env = {
        PRETTIERD_DEFAULT_CONFIG = vim.fn.expand('~/.config/nvim/.prettierrc.json'),
      },
    },
    -- lua 格式化配置
    formatting.stylua.with {
      extra_args = { '--config-path', vim.fn.expand('~/.config/nvim/.stylua.toml') },
    },

    formatting.clang_format.with {
      extra_args = { '--style=file:' .. vim.fn.stdpath('config') .. '/.clang-format' },
    },
    code_actions.gitsigns,
    diagnostics.flake8,
  },
}
