-- 自动安装 Packer.nvim
-- 插件安装目录
-- ~/.local/share/nvim/site/pack/packer/
local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local paccker_bootstrap
if fn.empty(fn.glob(install_path)) > 0 then
  vim.notify("正在安装Pakcer.nvim，请稍后...")
  paccker_bootstrap = fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    -- "https://gitcode.net/mirrors/wbthomason/packer.nvim",
    install_path,
  })
  -- https://github.com/wbthomason/packer.nvim/issues/750
  local rtp_addition = vim.fn.stdpath("data") .. "/site/pack/*/start/*"
  if not string.find(vim.o.runtimepath, rtp_addition) then
    vim.o.runtimepath = rtp_addition .. "," .. vim.o.runtimepath
  end
  vim.notify("Pakcer.nvim 安装完毕")
end


-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  vim.notify("没有安装 packer.nvim")
  return
end

packer.startup({
  function(use)
    -- 设置 packer 自动管理
    use('wbthomason/packer.nvim')
    -- 配置 onedock 主题
    -- use('navarasu/onedark.nvim')
    -- MonokaiPro 主题
    use('tanvirtin/monokai.nvim')
    -- use("cpea2506/one_monokai.nvim")
    -- 配置 onedarkpro 主题
    use({"olimorris/onedarkpro.nvim"})
    -- github 主题
    use({ 'projekt0n/github-nvim-theme' })
    -- lualine 状态栏装饰插件
    use({
      "nvim-lualine/lualine.nvim",
      requires = { "kyazdani42/nvim-web-devicons" },
    })
    use("arkav/lualine-lsp-progress")
    -- 配置 nvimtree 插件
    use({'kyazdani42/nvim-tree.lua', requires = 'kyazdani42/nvim-web-devicons'})
    -- 配置 bufferline 插件
    use({'akinsho/bufferline.nvim', requires = 'kyazdani42/nvim-web-devicons'})
    -- 配置高亮插件
    use({ 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'})
    -- 配置彩虹括号插件
    use("p00f/nvim-ts-rainbow")
    -- 配置 文件搜索插件
    use({
      'nvim-telescope/telescope.nvim',
      requires = { {'nvim-lua/plenary.nvim'} }
    })
    -- telescope extensions 扩展
    use("LinArcX/telescope-env.nvim")
    use("nvim-telescope/telescope-ui-select.nvim")
    -- dashboard-nvim 启动面板
    use("glepnir/dashboard-nvim")
    -- project 项目列表插件
    use("ahmedkhalf/project.nvim")
    -- indent-blankline 空白行缩进
    use("lukas-reineke/indent-blankline.nvim")
    -- 配置 surround 环绕插件
    use("ur4ltz/surround.nvim")
    -- Comment 注释插件
    use("numToStr/Comment.nvim")
    -- nvim-autopairs 括号补全
    use("windwp/nvim-autopairs")
  end
})
