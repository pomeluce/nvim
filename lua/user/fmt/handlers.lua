local function prettier(parser)
  local common_args = {
    '--stdin-filepath',
    vim.fn.shellescape(vim.api.nvim_buf_get_name(0), true),
    '--config',
    vim.fn.expand('~/.config/nvim/.prettierrc.json'),
  }

  local args = parser and vim.list_extend(common_args, { '--parser', parser }) or common_args

  return {
    exe = 'prettier',
    args = args,
    stdin = true,
    try_node_modules = true,
  }
end

require('formatter').setup {
  logging = true,
  log_level = vim.log.levels.WARN,
  filetype = {
    css = { prettier('css') },
    lua = {
      function()
        return {
          exe = 'stylua',
          args = {
            '--config-path',
            vim.fn.expand('~/.config/nvim/.stylua.toml'),
            '--',
            '-',
          },
          stdin = true,
        }
      end,
    },
    javascript = { prettier },
    javascriptreact = { prettier },
    json = { prettier },
    jsonc = { prettier },
    markdown = { prettier('markdown') },
    rust = {
      -- rules: https://rust-lang.github.io/rustfmt
      function()
        return {
          exe = 'rustfmt',
          args = {
            '--config-path',
            vim.fn.expand('~/.config/nvim/.rustfmt.toml'),
          },
          stdin = true,
        }
      end,
    },
    scss = { prettier('scss') },
    toml = {
      function()
        return {
          exe = 'taplo',
          args = {
            'fmt',
            '-',
            '--config',
            vim.fn.expand('~/.config/nvim/.taplo.toml'),
          },
          stdin = true,
          try_node_modules = true,
        }
      end,
    },
    typescript = { prettier('typescript') },
    typescriptreact = { prettier('typescript') },
    vue = { prettier('vue') },
    ['*'] = { require('formatter.filetypes.any').remove_trailing_whitespace },
  },
}
