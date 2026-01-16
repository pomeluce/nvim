vim.pack.add({
  { src = 'https://github.com/coffebar/neovim-project' },
  { src = 'https://github.com/Shatur/neovim-session-manager' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
})

vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

require('neovim-project').setup({
  -- projects = vim.list_extend({}, akirc.session.projects),
  projects = {
    '$DEVROOT/wsp/*',
    '$DEVROOT/code/web/*',
    '$DEVROOT/code/rust/*',
    '$DEVROOT/code/sql/*',
    '$DEVROOT/code/java/*',
    '$DEVROOT/code/cpp/*',
    '$DEVROOT/code/python/*',
    '$DEVROOT/code/scripts/*',
  },
  datapath = vim.fn.stdpath('data'),
  -- 非项目目录加载最后一次会话
  last_session_on_startup = false,
  -- 仪表盘模式, 开启取消自动加载
  dashboard_mode = false,
  -- Timeout in milliseconds before trigger FileType autocmd after session load
  -- to make sure lsp servers are attached to the current buffer.
  -- Set to 0 to disable triggering FileType autocmd
  filetype_autocmd_timeout = 200,
  session_manager_opts = {
    -- 在保存会话之前, 这些文件类型的所有缓冲区都将关闭
    autosave_ignore_filetypes = { 'gitcommit', 'gitrebase' },
    -- 不会自动保存会话的目录列表
    -- autosave_ignore_dirs = vim.list_extend({ vim.fn.expand('~'), '/' }, akirc.session.ignore_dir),
    autosave_ignore_dirs = vim.list_extend({ vim.fn.expand('~'), '/' }, { '~/downloads', '~/Downloads' }),
  },
  picker = {
    -- "telescope", "fzf-lua", "snacks"
    type = 'snacks',

    preview = {
      -- 在 Snacks 预览中显示目录结构
      enabled = true,
      -- 显示分支名称、领先/落后计数器以及每个文件/文件夹的 Git 状态
      git_status = true,
      -- 从远程获取, 用于显示超前/落后提交的数量, 需要 Git 授权
      git_fetch = false,
      -- 显示隐藏文件/文件夹
      show_hidden = true,
    },
    opts = { layout = 'dropdown' },
  },
})
