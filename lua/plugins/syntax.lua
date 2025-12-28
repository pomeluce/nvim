return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'master',
  event = { 'BufReadPost', 'BufNewFile' },
  dependencies = {
    { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'master' },
    'nvim-treesitter/nvim-treesitter-context',
    'JoosepAlviste/nvim-ts-context-commentstring',
  },
  build = ':TSUpdate',
  config = function() require('configs.treesitter') end,
}
