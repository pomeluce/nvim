local treesitter = require('user.configs.tree-sitter')

-- 语法高亮
return {
  'nvim-treesitter/nvim-treesitter',
  event = { 'BufReadPost', 'BufNewFile' },
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    'nvim-treesitter/nvim-treesitter-context',
    'JoosepAlviste/nvim-ts-context-commentstring',
  },
  main = 'nvim-treesitter.configs',
  build = ':TSUpdate',
  opts = treesitter.setup(),
  config = function(_, opts)
    require('nvim-treesitter.configs').setup(opts)
    -- 自动根据文件类型设置解析器
    treesitter.parser_bootstrap()
  end,
}
