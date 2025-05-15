return {
  'kndndrj/nvim-dbee',
  event = 'VeryLazy',
  dependencies = {
    'MunifTanjim/nui.nvim',
  },
  build = function()
    require('dbee').install()
  end,
  opts = require('user.configs.dbee').setup(),
}
