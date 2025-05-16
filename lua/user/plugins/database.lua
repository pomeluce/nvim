return {
  'kndndrj/nvim-dbee',
  event = 'VeryLazy',
  dependencies = {
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Dbee',
  build = function()
    require('dbee').install()
  end,
  opts = require('user.configs.dbee').setup(),
}
