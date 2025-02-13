local M = {}
local colors = require('user.configs.heirline.colors')

---@diagnostic disable: duplicate-index
M.modes = {
  ['n'] = { 'NORMAL', 'Normal' },
  ['no'] = { 'NORMAL (no)', 'Normal' },
  ['nov'] = { 'NORMAL (nov)', 'Normal' },
  ['noV'] = { 'NORMAL (noV)', 'Normal' },
  ['noCTRL-V'] = { 'NORMAL', 'Normal' },
  ['niI'] = { 'NORMAL i', 'Normal' },
  ['niR'] = { 'NORMAL r', 'Normal' },
  ['niV'] = { 'NORMAL v', 'Normal' },
  ['nt'] = { 'TERMINAL', 'NTerminal' },
  ['ntT'] = { 'TERMINAL (ntT)', 'NTerminal' },

  ['v'] = { 'VISUAL', 'Visual' },
  ['vs'] = { 'V-CHAR (Ctrl O)', 'Visual' },
  ['V'] = { 'V-LINE', 'Visual' },
  ['Vs'] = { 'V-LINE', 'Visual' },
  ['\22'] = { 'V-BLOCK', 'Visual' },
  ['\22s'] = { 'V-BLOCK', 'Visual' },
  [''] = { 'V-BLOCK', 'Visual' },

  ['i'] = { 'INSERT', 'Insert' },
  ['ic'] = { 'INSERT (completion)', 'Insert' },
  ['ix'] = { 'INSERT completion', 'Insert' },

  ['t'] = { 'TERMINAL', 'Terminal' },

  ['R'] = { 'REPLACE', 'Replace' },
  ['Rc'] = { 'REPLACE (Rc)', 'Replace' },
  ['Rx'] = { 'REPLACEa (Rx)', 'Replace' },
  ['Rv'] = { 'V-REPLACE', 'Replace' },
  ['Rvc'] = { 'V-REPLACE (Rvc)', 'Replace' },
  ['Rvx'] = { 'V-REPLACE (Rvx)', 'Replace' },

  ['s'] = { 'SELECT', 'Select' },
  ['S'] = { 'S-LINE', 'Select' },
  [''] = { 'S-BLOCK', 'Select' },
  ['c'] = { 'COMMAND', 'Command' },
  ['cv'] = { 'COMMAND', 'Command' },
  ['ce'] = { 'COMMAND', 'Command' },
  ['cr'] = { 'COMMAND', 'Command' },
  ['r'] = { 'PROMPT', 'Confirm' },
  ['rm'] = { 'MORE', 'Confirm' },
  ['r?'] = { 'CONFIRM', 'Confirm' },
  ['x'] = { 'CONFIRM', 'Confirm' },
  ['!'] = { 'SHELL', 'Terminal' },
}
M.mode_hl = {
  ['Normal'] = colors.green,
  ['NTerminal'] = colors.green,
  ['Insert'] = colors.blue,
  ['Visual'] = colors.dark_purple,
  ['Select'] = colors.dark_purple,
  ['Terminal'] = colors.cyan,
  ['Confirm'] = colors.orange,
  ['Command'] = colors.sun,
}

M.stbufnr = function()
  return vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
end

M.space = setmetatable({ provider = ' ' }, {
  __call = function(_, n)
    return { provider = string.rep(' ', n) }
  end,
})

M.file_icon = {
  init = function(self)
    local filename = vim.fn.fnamemodify(self.filename, ':t')
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true, strict = true })
  end,
  provider = function(self)
    return self.icon and (' ' .. self.icon .. ' ')
  end,
  hl = function(self)
    return { fg = self.icon_color }
  end,
}

M.align = { provider = '%=' }

M.fmt = {
  unix = '', -- e712
  dos = '', -- e70f
  mac = '', -- e711
}

M.separators = { left = '', right = '' }

M.close_current_tab_buffer = function()
  -- 获取当前 tab 页的所有 buffer
  local buffers = vim.api.nvim_list_bufs()
  for _, buf in ipairs(buffers) do
    -- 确保 buffer 是在当前 tab 中的，并且是有效 buffer
    if vim.api.nvim_buf_is_loaded(buf) and vim.fn.bufwinnr(buf) ~= -1 then
      -- 关闭 buffer (不保存更改)
      vim.cmd('bdelete! ' .. buf)
    end
  end
end

M.get_tabnr_from_bufnr = function(bufnr)
  -- 获取当前窗口的编号
  local winid = vim.fn.bufwinid(bufnr)

  -- 检查 buffer 是否在任何窗口中
  if winid == -1 then
    return nil -- 如果 buffer 没有打开，返回 nil
  end

  -- 获取窗口所在的 tab 页编号
  return vim.api.nvim_tabpage_get_number(vim.api.nvim_win_get_tabpage(winid))
end

return M
