local M = {

  -- markdown preview default browser
  mkdp_browser = '',

  -- session 保存忽略目录
  ignore_session_dir = { '~/Downloads' },

  -- 文件默认运行方式
  --[[
      javascript = 'node',
      typescript = 'ts-node',
      html = 'firefox',
      python = 'python',
      go = 'go run',
      sh = 'bash',
      lua = 'lua'
  ]]
  run_cmd = {},

  -- 搜索参数
  grep_args = {},

  -- 项目列表
  projects = {
    '/wsp/nvim',
    '/wsp/dzs',
    '/wsp/dotfiles',
    '/wsp/dotfiles/ags',
    '/wsp/code/web/*',
    '/wsp/code/rust/*',
    '/wsp/code/sql/*',
    '/wsp/code/java/*',
    '/wsp/code/cpp/*',
  },
}

return M
