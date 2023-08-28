local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  return {
    -- 激活
    active = true,
    on_config_done = nil,
    -- 手动模式
    manual_mode = false,
    -- 检测根目录
    detection_methods = { 'pattern' },
    patterns = { '.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', 'package.json', '.idea', 'vscode', '.prettierrc.js', '.prettierrc.json' },
    -- 显示隐藏文件
    show_hidden = true,
    -- 更改目录是不接受消息
    silent_chdir = true,
    -- lsp 检测忽略列表
    ignore_lsp = {},
    -- 储存项目的历史路径
    datapath = vim.fn.stdpath('data'),
  }
end

return M
