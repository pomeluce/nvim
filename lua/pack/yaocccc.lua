local G = require('G')
local M = {}

function M.config()
  -- vim-surround
  G.g.use_toggle_surround = 0

  -- vim-echo
  G.map({
    { 'v', 'C', ':<c-u>VECHO<cr>', G.opt },
  })
  G.g.vim_echo_by_file = { js = 'console.log([ECHO])', ts = 'console.log([ECHO])', vue = 'console.log([ECHO])', }

  -- vim-comment
  G.g.vim_line_comments = {
    c = '//',
    class = '//',
    go = '//',
    h = '//',
    java = '//',
    js = '//',
    ['go.mod'] = '//',
    lua = '--',
    md = '[^_^]:',
    proto = '//',
    sol = '//',
    sql = '--',
    ts = '//',
    vim = '"',
    vimrc = '"',
    vue = '//',
  }
  G.g.vim_chunk_comments = {
    js = { '/**', ' *', ' */' },
    md = { '[^_^]:', '    ', '' },
    proto = { '/**', ' *', ' */' },
    sh = { ':<<!', '', '!' },
    sol = { '/**', ' *', ' */' },
    ts = { '/**', ' *', ' */' },
    vue = { '/**', ' *', ' */' },
  }
  G.map({
    -- n 模式下, 行注释
    { 'n', '??', ':NToggleComment<cr>', G.opt },
    -- v 模式下, 行注释
    { 'v', '?', ':<c-u>VToggleComment<cr>', G.opt },
    -- v 模式下, 块注释
    { 'v', '/', ':<c-u>CToggleComment<cr>', G.opt },
  })
end

function M.setup()
  -- do nothing
end

return M
