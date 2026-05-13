local M = {}

local map = vim.keymap.set
local terminals = {}

function M.floaterm(name, cmd, close, opts)
  local Terminal = require('toggleterm.terminal').Terminal
  if terminals[name] and cmd ~= '' and terminals[name].cmd ~= cmd then
    if terminals[name]:is_open() then terminals[name]:toggle() end
    terminals[name] = nil
  end
  if not terminals[name] then
    terminals[name] = Terminal:new({
      cmd = cmd ~= '' and cmd or nil,
      display_name = name,
      dir = 'git_dir',
      close_on_exit = close or false,
      float_opts = opts,
      hidden = true,
      on_open = function(_) vim.cmd('startinsert!') end,
    })
  end

  if name == 'TERM' then terminals[name].dir = vim.fn.getcwd() end
  if name == 'RUN' then terminals[name].dir = vim.fn.fnamemodify(vim.fn.expand('%'), ':p:h') end

  terminals[name]:toggle()
end

function M.setToggleKey(key, name, cmd, opts)
  map('n', key, function() require('configs.terminal').floaterm(name, cmd, true, opts) end, { desc = 'toggle floaterm' })
  map('t', key, function()
    local term = terminals[name]
    if term and term:is_open() then
      term:toggle()
    else
      vim.api.nvim_feedkeys(key, 't', false)
    end
  end, { desc = 'toggle floaterm' })
end

function M.runFile()
  vim.cmd('w')
  local ft = vim.api.nvim_eval('&ft')
  local file = vim.fn.expand('%:p')
  local file_root = vim.fn.expand('%:p:r')

  local run_cmd = vim.list_extend({
    javascript = 'node',
    typescript = 'ts-node',
    html = 'firefox',
    python = 'python3',
    go = 'go run',
    sh = 'bash',
    lua = 'lua',
  }, require('settings').file.run_cmd)

  if run_cmd[ft] then
    M.floaterm('RUN', string.format('%s %s', run_cmd[ft], file))
  elseif ft == 'markdown' then
    vim.cmd('MarkdownPreview')
  elseif ft == 'java' then
    M.floaterm('RUN', string.format('javac %s && java %s', file, file_root))
  elseif ft == 'c' then
    M.floaterm('RUN', string.format('gcc %s -o %s && ./%s && rm %s', file, file_root, file_root, file_root))
  elseif ft == 'rust' then
    M.floaterm('RUN', string.format('rustc % -o %s && ./%s && rm %s', file, file_root, file_root, file_root))
  end
end

return M
