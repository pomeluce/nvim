local function preitter(parser)
  local common_args = {
    '--stdin-filepath',
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
    css = { preitter('css') },
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
    javascript = { preitter },
    javascriptreact = { preitter },
    json = { preitter },
    markdown = { preitter },
    typescript = { preitter('typescript') },
    typescriptreact = { preitter('typescript') },
    vue = { preitter('vue') },
    ['*'] = {
      require('formatter.filetypes.any').remove_trailing_whitespace,
    },
  },
}
