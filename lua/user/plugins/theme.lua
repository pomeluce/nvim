return {
  {
    'loctvl842/monokai-pro.nvim',
    config = function()
      local monokai = require('monokai-pro')
      monokai.setup(require('user.configs.colorscheme').setup())
      monokai.load()
    end,
  },
}
