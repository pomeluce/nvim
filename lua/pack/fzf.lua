local G = require('G')
local M = {}

function M.config()
  G.g.fzf_preview_window = { 'right,40%,<50(down,50%)', 'ctrl-/' }
  G.g.fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'
  G.g.fzf_layout = {
    window = {
      width = 0.9,
      height = 0.8
    }
  }
  G.cmd("com! -bar -bang Ag call fzf#vim#ag(<q-args>, fzf#vim#with_preview({'options': '--delimiter=: --nth=4..'}), <bang>0)")
  G.cmd("com! CHistory call CHistory()")
  G.cmd([[
    func! CHistory()
      call filter(v:oldfiles, "v:val =~ '^' . $PWD . '.*$'")
      call fzf#vim#history(fzf#vim#with_preview(), 0)
    endf
    ]])
  G.map({
    -- 全局文本搜索(yay -S the_silver_searcher fd bat)
    { 'n', '<leader>ft', ':Ag<cr>', { noremap = true, silent = true } },
    -- 文件列表查找
    { 'n', '<leader>ff', ':Files<cr>', { noremap = true, silent = true } },
    -- 当前文本内容查找
    { 'n', '<leader>fw', ':BLines<cr>', { noremap = true, silent = true } },
    -- git 文件查找
    { 'n', '<leader>fg', ':GFiles?<cr>', { noremap = true, silent = true } },
    -- 查看历史文件
    { 'n', '<leader>fh', ':CHistory<cr>', { noremap = true, silent = true } },
  })
end

function M.setup()
  -- do nothing
end

return M
