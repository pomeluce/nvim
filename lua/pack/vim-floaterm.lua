local G = require('G')
local M = {}

function FTToggle(name, cmd, pre_cmd)
  if G.fn['floaterm#terminal#get_bufnr'](name) ~= -1 then
    G.cmd(string.format('exec "FloatermToggle %s"', name))
  else
    G.cmd(string.format('exec "%s"', pre_cmd))
    G.cmd(string.format('FloatermNew --autoclose=0 --name=%s %s', name, cmd))
  end
end

function SetFTToggleMap(key, name, cmd, pre_cmd)
  G.map({
    { 'n', key, string.format(":call v:lua.FTToggle('%s', '%s', '%s')<cr>", name, cmd, pre_cmd), G.opt },
    { 't', key,
      "&ft == \"floaterm\" ? printf('<c-\\><c-n>:FloatermHide<cr>%s', floaterm#terminal#get_bufnr('" ..
          name .. "') == bufnr('%') ? '' : '" .. key .. "') : '" .. key .. "'", { silent = true, expr = true } },
  })
end

function M.config()
  local run_cmd = { javascript = 'node', typescript = 'ts-node', html = 'firefox', python = 'python', go = 'go run',
    sh = 'bash', lua = 'lua' }
  G.g.floaterm_title = ''
  G.g.floaterm_width = 0.8
  G.g.floaterm_height = 0.8
  G.g.floaterm_autoclose = 1
  G.g.floaterm_opener = 'edit'
  G.cmd("au BufEnter * if &buftype == 'terminal' | :call timer_start(50, { -> execute('startinsert!') }, { 'repeat': 3 }) | endif")
  G.cmd("hi FloatermBorder ctermfg=fg ctermbg=none")
  function RunFile()
    G.cmd('w')
    local ft = G.eval('&ft')
    if run_cmd[ft] then FTToggle('RUN', run_cmd[ft] .. ' %', '')
    elseif ft == 'markdown' then G.cmd('MarkdownPreview')
    elseif ft == 'java' then FTToggle('RUN', 'javac % && java %<', '')
    elseif ft == 'c' then FTToggle('RUN', 'gcc % -o %< && ./%< && rm %<', '')
    end
  end

  G.cmd([[
        func! SetVimDir()
            try
                call system('echo "' . $PWD . '" > $ZSH/cache/vimdir')
            endtry
        endf
    ]])

  -- 打开数据库可视化工具
  SetFTToggleMap('<c-b>', 'DBUI', 'nvim +CALLDB', '')
  -- 代开浮动终端
  SetFTToggleMap('<c-t>', 'TERM', '', 'call SetVimDir()')
  -- 根据文件类型启动浮动终端执行当前文件
  G.map({
    { 'n', '<F5>', ':call v:lua.RunFile()<cr>', G.opt },
    { 'i', '<F5>', '<esc>:call v:lua.RunFile()<cr>', G.opt },
    { 't', '<F5>',
      "&ft == \"floaterm\" ? printf('<c-\\><c-n>:FloatermHide<cr>%s', floaterm#terminal#get_bufnr('RUN') == bufnr('%') ? '' : '<F5>') : '<F5>'",
      { silent = true, expr = true } }
  })
end

function M.setup()
  -- do nothing
end

return M
