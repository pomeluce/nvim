return require('packer').startup(function()
  -- 设置 packer 自动管理
  use 'wbthomason/packer.nvim'
  -- 配置 onedock 主题
  -- use 'navarasu/onedark.nvim'
  -- 配置 onedarkpro 主题
  use({"olimorris/onedarkpro.nvim", config = function()
    require("onedarkpro").setup()
  end
  })
  -- 配置 nvimtree 插件
  use {'kyazdani42/nvim-tree.lua', requires = 'kyazdani42/nvim-web-devicons'}
  -- 配置 bufferline 插件
  use {'akinsho/bufferline.nvim', requires = 'kyazdani42/nvim-web-devicons'}
  -- 配置高亮插件
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
end)
