local fn = vim.fn
local lazypath = fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  print('Installing lazy.nvim...')
  fn.system { 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({ require('core.nvchad'), { import = 'plugins' } }, {
  defaults = { lazy = true },
  install = { colorscheme = { 'nvchad' } },
  ui = { icons = { ft = '', lazy = '󰂠 ', loaded = '', not_loaded = '' }, border = require('akirc').ui.borderStyle },
})
