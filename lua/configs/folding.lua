vim.opt.foldcolumn = '0'
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.opt.foldmethod = 'expr'
vim.opt.fillchars = [[fold: ,stlnc:·,eob: ,foldsep:=,foldopen:,foldclose:]]
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.viewdir = vim.fn.stdpath('cache') .. '/viewdir'
vim.opt.viewoptions:append('folds')

function _G.intelli_foldtext()
  local start_text = vim.fn.getline(vim.v.foldstart)
  local indent = start_text:match('^%s*') or ''
  local content = start_text:sub(#indent + 1)
  local nline = vim.v.foldend - vim.v.foldstart
  local result = { { indent, 'Folded' }, { '󰛂  ' .. nline .. ' lines folded  ', 'Comment' }, { content, 'Folded' } }
  return result
end

vim.opt.foldtext = 'v:lua.intelli_foldtext()'
