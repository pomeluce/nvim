return {
  condition = function(self)
    local win = vim.api.nvim_tabpage_list_wins(0)[1]
    local bufnr = vim.api.nvim_win_get_buf(win)
    self.winid = win

    if vim.bo[bufnr].filetype == 'NvimTree' then
      self.title = 'FileBrowser'
      return true
    end
  end,

  provider = function(self)
    local title = self.title
    local width = vim.api.nvim_win_get_width(self.winid)
    local pad = math.ceil(width - #title)
    return '  ' .. title .. string.rep(' ', pad - 2)
  end,

  hl = function(self)
    if vim.api.nvim_get_current_win() == self.winid then
      return 'TablineSel'
    else
      return 'Tabline'
    end
  end,
}
