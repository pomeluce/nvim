local M = {}

local map = require('user.core.mappings').map
local terminals = {}

function M.floaterm(name, cmd, close)
  local Terminal = require('toggleterm.terminal').Terminal
  if not terminals[name] then
    terminals[name] = Terminal:new {
      cmd = cmd ~= '' and cmd or nil,
      display_name = name,
      dir = 'git_dir',
      close_on_exit = close or false,
      hidden = true,
      on_open = function(_)
        vim.cmd('startinsert!')
      end,
    }
  end

  if name == 'TERM' then
    terminals[name].dir = vim.fn.getcwd()
  end

  terminals[name]:toggle()
end

function M.setToggleKey(key, name, cmd)
  map('n', key, string.format(":lua require('user.configs.toggleterm').floaterm('%s', '%s', %s)<cr>", name, cmd, true), { desc = 'toggle floaterm' })
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
  local file = vim.fn.expand('%')
  local file_root = vim.fn.expand('%:r')

  local run_cmd = vim.list_extend({
    javascript = 'node',
    typescript = 'ts-node',
    html = 'firefox',
    python = 'python',
    go = 'go run',
    sh = 'bash',
    lua = 'lua',
  }, require('akirc').file.run_cmd or {})

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

function M.config()
  M.setToggleKey('<C-t>', 'TERM', '')
  M.setToggleKey('<C-p>', 'RANGER', 'ranger')
end

function M.setup()
  return {
    direction = 'float',
    highlights = {
      FloatBorder = { link = 'FloatBorder' },
    },
    float_opts = {
      border = require('akirc').ui.borderStyle,
      width = 120,
      height = 40,
      title_pos = 'center',
    },
  }
end

return M
