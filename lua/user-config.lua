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
}

return M
