local M = {}

function M.fHistory()
  vim.cmd([[
    call filter(v:oldfiles, "v:val =~ '^' . $PWD . '.*$'")
    call fzf#vim#history(fzf#vim#with_preview(), 0)
  ]])
end

function M.config()
  -- 设置布局为自上而下
  vim.cmd([[ 
    let $FZF_DEFAULT_OPTS = "--layout=reverse"
  ]])
  vim.g.fzf_preview_window = { 'right,40%,<50(down,50%)', 'ctrl-/' }
  vim.g.fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'
  vim.g.fzf_layout = {
    window = {
      width = 0.9,
      height = 0.8,
    },
  }
  vim.cmd("com! -bar -bang Ag call fzf#vim#ag(<q-args>, fzf#vim#with_preview({'options': '--delimiter=: --nth=4..'}), <bang>0)")
  vim.cmd("com! FHistory lua require('pack/fzf').fHistory()")
end

function M.setup()
  -- do nothing
end

return M
