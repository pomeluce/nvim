vim.g.switch_custom_definitions = {
  { '> [!TODO]', '> [!WIP]', '> [!DONE]', '> [!FAIL]' },
  { '- [ ]', '- [>]', '- [x]' },
  { 'height', 'width' },
}

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function() PackUtils.load({ name = 'switch.vim' }) end,
})
