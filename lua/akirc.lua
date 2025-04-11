local M = {}

M.ui = {
  borderStyle = 'rounded',
}

M.hl = {
  winSeparator = { fg = '#676b6e' },
}

-- markdown preview default browser
M.mkdp_browser = ''

-- session 保存忽略目录
M.ignore_session_dir = { '~/Downloads' }

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
M.run_cmd = {}

-- 搜索参数
M.grep_args = {}

-- 项目列表
M.projects = {
  '/wsp/akir-shell',
  '/wsp/akir-zimfw',
  '/wsp/nvim',
  '/wsp/dotfiles',
  '/wsp/code/web/*',
  '/wsp/code/rust/*',
  '/wsp/code/sql/*',
  '/wsp/code/java/*',
  '/wsp/code/cpp/*',
}

return M
