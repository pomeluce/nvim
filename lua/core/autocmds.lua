local function augroup(name) return vim.api.nvim_create_augroup('Lazy' .. name, { clear = true }) end

-- 自动切换输入法
vim.api.nvim_create_autocmd('InsertLeave', {
  group = vim.api.nvim_create_augroup('ToggelInput', { clear = true }),
  pattern = '*',
  callback = function()
    if vim.api.nvim_get_mode().mode == 'n' then vim.fn.system('busctl call --user org.fcitx.Fcitx5 /rime org.fcitx.Fcitx.Rime1 SetAsciiMode b 1') end
  end,
})

-- 自动高亮复制的文本
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('HighlightYank', { clear = true }),
  callback = function() vim.hl.on_yank({ higroup = 'CurSearch' }) end,
})

-- 用 o 换行不要延续注释
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('WrapComment', { clear = true }),
  pattern = '*',
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions
      - 'o' -- O 和 o, 不要延续注释
      + 'r' -- 回车延续注释
  end,
})

-- 自动恢复上次编辑位置
vim.api.nvim_create_autocmd({ 'BufReadPost' }, {
  pattern = { '*' },
  callback = function() vim.api.nvim_exec2('silent! normal! g`"zv', { output = false }) end,
})

-- 大文件优化
vim.filetype.add({
  pattern = {
    ['.*'] = {
      function(path, buf)
        if vim.bo[buf].filetype ~= 'bigfile' and path and vim.fn.getfsize(path) > vim.g.bigfile_size then
          vim.opt.cursorline = false
          return 'bigfile'
        else
          return nil
        end
      end,
    },
  },
})
vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = augroup('Bigfile'),
  pattern = 'bigfile',
  callback = function(ev)
    vim.b.minianimate_disable = true
    vim.schedule(function() vim.bo[ev.buf].syntax = vim.filetype.match({ buf = ev.buf }) or '' end)
  end,
})

-- 自动保存折叠信息
local foldGroup = vim.api.nvim_create_augroup('PersistFolds', { clear = true })
vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWinEnter' }, {
  group = foldGroup,
  pattern = '*',
  callback = function() vim.cmd([[ silent! loadview ]]) end,
})
vim.api.nvim_create_autocmd({ 'BufWinLeave', 'VimLeavePre' }, {
  group = foldGroup,
  pattern = '*',
  callback = function() vim.cmd([[ silent! mkview ]]) end,
})

-- 修改终端 buffer 名称
vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('SetTermBufName', { clear = true }),
  pattern = 'term://*',
  callback = function(args)
    local bufnr = args.buf
    local api = vim.api
    local is_float = false

    -- 一个 buffer 可能在多个窗口中, 这里逐个检查
    for _, win in ipairs(api.nvim_list_wins()) do
      if api.nvim_win_get_buf(win) == bufnr then
        local cfg = api.nvim_win_get_config(win)
        if cfg.relative ~= '' then
          is_float = true
          break
        end
      end
    end
    api.nvim_buf_set_name(bufnr, string.format('%s[%d]', is_float and 'FloatTerm' or 'Terminal', bufnr))
  end,
})

-- vim.pack.update buffer 快捷键绑定
local function is_pack_buf(bufnr)
  if not vim.api.nvim_buf_is_loaded(bufnr) then return false end
  local name = vim.api.nvim_buf_get_name(bufnr) or ''
  return name:match('^nvim%-pack://confirm') ~= nil
end
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('PackKeyBind', { clear = true }),
  pattern = 'nvim-pack://confirm*',
  callback = function(event)
    -- 关闭其他 nvim-pack buffer, 保证 pack 更新 buffer 始终只有一个
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if is_pack_buf(bufnr) and bufnr ~= event.buf then pcall(vim.api.nvim_buf_delete, bufnr, { force = true }) end
    end

    local map = vim.keymap.set
    map('n', 'S', '<cmd>write<cr>', { buffer = event.buf, desc = 'Confirm and update all plugin' })
    map('n', 'R', '<cmd>PackUpdate<cr>', { buffer = event.buf, desc = 'Retry plugin update' })
    map('n', 'q', '<cmd>close<cr>', { buffer = event.buf, desc = 'Close plugin confirmation buffer' })
    map('n', '<esc>', '<cmd>close<cr>', { buffer = event.buf, desc = 'Close plugin confirmation buffer' })
  end,
})
