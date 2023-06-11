local fn = vim.fn
local packer_bootstrap = false
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local compiled_path = fn.stdpath('config') .. '/plugin/packer_compiled.lua'
if fn.empty(fn.glob(install_path)) > 0 then
  print('Installing packer.nvim...')
  fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path }
  fn.system { 'rm', '-rf', compiled_path }
  vim.cmd([[packadd packer.nvim]])
  packer_bootstrap = true
end

-- 所有插件配置分 config 和 setup 部分
-- config 发生在插件载入前 一般为 let g:xxx = xxx 或者 hi xxx xxx 或者 map x xxx 之类的 配置
-- setup  发生在插件载入后 一般为 require('xxx').setup() 之类的配置
require('packer').startup {
  function(use)
    -- packer 管理自己的版本
    use { 'wbthomason/packer.nvim' }

    -- 启动时间分析
    use { 'dstein64/vim-startuptime', cmd = 'StartupTime' }

    -- 中文help doc
    use { 'yianwillis/vimcdoc', event = 'VimEnter' }

    -- 配置主题
    use { 'cpea2506/one_monokai.nvim', config = "require('user.plugins.colorscheme').setup()" }

    -- coc 配置
    use { 'neoclide/coc.nvim', config = "require('user.plugins.coc').setup()", branch = 'release' }

    -- vv 快速选中内容插件
    use { 'terryma/vim-expand-region', event = 'CursorHold' }

    -- ff 高亮光标下的 word
    use {
      'lfv89/vim-interestingwords',
      config = "require('user.plugins.vim-interestingwords').setup()",
      event = 'CursorHold',
    }

    -- 多光标插件
    use {
      'mg979/vim-visual-multi',
      config = "require('user.plugins.vim-visual-multi').setup()",
      event = 'CursorHold',
    }

    -- 数据库可视化UI
    use { 'tpope/vim-dadbod', cmd = { 'DBUI' } }
    use {
      'kristijanhusak/vim-dadbod-ui',
      config = "require('user.plugins.vim-dadbod').setup()",
      after = 'vim-dadbod',
    }

    -- structs 列表
    use { 'simrat39/symbols-outline.nvim', config = "require('user.plugins.symbols-outline').setup()" }

    -- github copilot
    use { 'github/copilot.vim', config = "require('user.plugins.copilot').setup()", event = 'InsertEnter' }

    -- 浮动终端
    use { 'voldikss/vim-floaterm', config = "require('user.plugins.vim-floaterm').setup()" }

    -- telescope 文件搜索
    use {
      'nvim-telescope/telescope.nvim',
      config = "require('user.plugins.telescope').setup()",
      branch = '0.1.x',
      requires = { { 'nvim-lua/plenary.nvim' } },
    }
    use { 'nvim-telescope/telescope-media-files.nvim' }

    -- 项目管理
    use { 'ahmedkhalf/project.nvim', config = "require('user.plugins.project').setup()" }

    -- tree-sitter
    use {
      'nvim-treesitter/nvim-treesitter',
      config = "require('user.plugins.tree-sitter').setup()",
      run = ':TSUpdate',
      event = 'BufRead',
    }
    use { 'nvim-treesitter/playground', after = 'nvim-treesitter' }

    -- 文件管理器
    use {
      'nvim-tree/nvim-tree.lua',
      config = "require('user.plugins.nvim-tree').setup()",
      cmd = { 'NvimTreeToggle', 'NvimTreeFindFileToggle', 'NvimTreeOpen' },
    }

    -- markdown 预览插件 导航生成插件
    use { 'mzlogin/vim-markdown-toc', ft = 'markdown' }
    use {
      'iamcco/markdown-preview.nvim',
      config = "require('user.plugins.markdown').setup()",
      run = 'cd app && yarn install',
      cmd = 'MarkdownPreview',
      ft = 'markdown',
    }

    -- 标题栏
    use {
      'akinsho/bufferline.nvim',
      config = "require('user.plugins.bufferline').setup()",
      tag = 'v3.*',
      requires = 'nvim-tree/nvim-web-devicons',
    }

    -- 状态栏
    use {
      'nvim-lualine/lualine.nvim',
      config = "require('user.plugins.lualine').setup()",
      requires = { 'nvim-tree/nvim-web-devicons', opt = true },
    }

    -- 代码注释
    use { 'numToStr/Comment.nvim', config = "require('user.plugins.comment').setup()" }

    -- 空白行缩进
    use {
      'lukas-reineke/indent-blankline.nvim',
      config = "require('user.plugins.indentline').setup()",
      after = 'nvim-treesitter',
    }

    -- 字符环绕
    use { 'tpope/vim-surround' }

    -- 启动面板
    use {
      'glepnir/dashboard-nvim',
      config = "require('user.plugins.dashboard').setup()",
      requires = { 'nvim-tree/nvim-web-devicons' },
    }

    -- session 管理
    use { 'rmagatti/auto-session', config = "require('user.plugins.session').setup()" }

    -- 代码折叠
    use { 'yaocccc/nvim-foldsign', config = 'require("nvim-foldsign").setup()', event = 'CursorHold' }
  end,
  -- 窗口浮动显示
  config = {
    git = { clone_timeout = 120, depth = 1 },
    display = {
      working_sym = '[ ]',
      error_sym = '[✗]',
      done_sym = '[✓]',
      removed_sym = ' - ',
      moved_sym = ' → ',
      header_sym = '─',
      open_fn = function()
        return require('packer.util').float { border = 'rounded' }
      end,
    },
  },
}

if packer_bootstrap then
  require('packer').sync()
end
