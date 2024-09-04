return {
  'mhartington/formatter.nvim',
  event = 'VeryLazy',
  config = function()
    require('user.fmt.handlers')
  end,
}
