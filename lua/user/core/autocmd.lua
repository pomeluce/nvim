local autoGroup = vim.api.nvim_create_augroup('autoGroup', { clear = true })
local autocmd = vim.api.nvim_create_autocmd

-- 修改 lua/packinit.lua 自动更新插件
autocmd('BufWritePost', {
  group = autoGroup,
  callback = function()
    if vim.fn.expand('%:t') == 'plugins-setup.lua' then
      vim.cmd('source ~/.config/nvim/lua/user/plugins-setup.lua | PackerSync')
    end
  end,
})

-- 用 o 换行不要延续注释
autocmd('BufEnter', {
  group = autoGroup,
  pattern = '*',
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions
        - 'o' -- O 和 o, 不要延续注释
        + 'r' -- 回车延续注释
  end,
})

-- 自动切换只读模式为可写模式
autocmd('BufEnter', {
  group = autoGroup,
  pattern = '*',
  callback = function()
    if vim.fn.getbufvar(0, '&buftype') == '' and vim.fn.getbufvar(0, '&readonly') == 1 then
      vim.cmd([[
        setlocal buftype=acwrite
        setlocal noreadonly
      ]])
    end
  end,
})

-- 自动保存折叠信息
autocmd('FileType', {
  group = autoGroup,
  pattern = '*',
  callback = function()
    pcall(vim.cmd, [[ silent! mkview ]])
  end,
})
autocmd('BufLeave,BufWinEnter', {
  group = autoGroup,
  pattern = '*',
  callback = function()
    pcall(vim.cmd, [[ silent! loadview ]])
  end,
})

-- 设置 git 高亮组
local highlightGroup = vim.api.nvim_create_augroup('custom_theme_highlights', { clear = true })
autocmd('BufReadPost', {
  group = highlightGroup,
  pattern = '*',
  callback = function()
    vim.cmd('highlight GitSignsAdd guifg=#43a047')
    vim.cmd('highlight GitSignsChange guifg=#fbc02d')
    vim.cmd('highlight GitSignsDetele guifg=#f44336')
  end,
})
