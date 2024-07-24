local M = {}

function M.config()
  vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'
end

function M.setup(config)
  return {
    -- 保存会话文件的目录
    sessions_dir = vim.fn.stdpath('data') .. '/sessions/',

    -- Function that replaces symbols into separators and colons to transform filename into a session directory.
    -- session_filename_to_dir = session_filename_to_dir,
    -- Function that replaces separators and colons into special symbols to transform session directory into a filename. Should use `vim.uv.cwd()` if the passed `dir` is `nil`.
    -- dir_to_session_filename = dir_to_session_filename,

    -- 定义当 neovim 不带参数启动时要做什么, 请参阅下面的"自动加载模式"部分
    autoload_mode = config.AutoloadMode.LastSession,
    -- 在退出和会话切换时自动保存最后一个会话
    autosave_last_session = true,
    -- 当没有打开缓冲区, 或者所有缓冲区都不可写或不可列出时, 插件不会保存会话
    autosave_ignore_not_normal = true,
    -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
    -- 不会自动保存会话的目录列表
    autosave_ignore_dirs = {},
    -- 在保存会话之前, 这些文件类型的所有缓冲区都将关闭
    autosave_ignore_filetypes = {
      'gitcommit',
      'gitrebase',
    },
    -- 在保存会话之前, 这些缓冲区类型的所有缓冲区都将关闭
    autosave_ignore_buftypes = {},
    -- 始终自动保存会话, 如果为 true, 则仅在会话处于活动状态后自动保存
    autosave_only_in_session = false,
    -- 如果长度超过此阈值, 则缩短显示路径, 如果根本不想缩短路径, 请使用 0
    max_path_length = 80,
  }
end

return M
