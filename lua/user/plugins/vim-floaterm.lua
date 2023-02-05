local M = {}
local keymap = vim.api.nvim_set_keymap

function M.toggleFT(name, cmd)
  if vim.fn['floaterm#terminal#get_bufnr'](name) ~= -1 then
    vim.cmd(string.format('exec "FloatermToggle %s"', name))
  else
    vim.cmd(string.format('FloatermNew --name=%s %s', name, cmd))
  end
end

function M.setFTToggleMap(key, name, cmd)
    keymap( 'n', key, string.format(":lua require('user.plugins.vim-floaterm').toggleFT('%s', '%s')<cr>", name, cmd), { noremap = true, silent = true } )
    keymap( 't', key,
    "&ft == \"floaterm\" ? printf('<c-\\><c-n>:FloatermHide<cr>%s', floaterm#terminal#get_bufnr('" ..
    name .. "') == bufnr('%') ? '' : '" .. key .. "') : '" .. key .. "'", { silent = true, expr = true } )
end

function M.runFile()
  vim.cmd('w')
  local ft = vim.api.nvim_eval('&ft')
  local run_cmd = { javascript = 'node', typescript = 'ts-node', html = 'firefox', python = 'python', go = 'go run',
    sh = 'bash', lua = 'lua' }
  if run_cmd[ft] then M.toggleFT('RUN', run_cmd[ft] .. ' %')
  elseif ft == 'markdown' then vim.cmd('MarkdownPreview')
  elseif ft == 'java' then M.toggleFT('RUN', 'javac % && java %<')
  elseif ft == 'c' then M.toggleFT('RUN', 'gcc % -o %< && ./%< && rm %<')
  end
end

function M.config()
  vim.g.floaterm_title = ''
  vim.g.floaterm_width = 0.8
  vim.g.floaterm_height = 0.8
  vim.g.floaterm_autoclose = 1
  vim.g.floaterm_opener = 'edit'
  vim.cmd("au BufEnter * if &buftype == 'terminal' | :call timer_start(50, { -> execute('startinsert!') }, { 'repeat': 3 }) | endif")
  -- 打开数据库可视化工具
  M.setFTToggleMap('<c-b>', 'DBUI', 'nvim +CALLDB')
  -- 打开浮动终端
  M.setFTToggleMap('<c-t>', 'TERM', '')
  -- 打开 ranger 终端文件管理器
  M.setFTToggleMap('<c-p>', 'RANGER', 'ranger')
end

function M.setup()
  -- do nothing
end

return M
