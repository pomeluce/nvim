local treesitter = require('user.plugins.tree-sitter')

-- 语法高亮
return {
  'nvim-treesitter/nvim-treesitter',
  event = 'VeryLazy',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    'nvim-treesitter/nvim-treesitter-context',
    'JoosepAlviste/nvim-ts-context-commentstring',
    'windwp/nvim-ts-autotag',
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
