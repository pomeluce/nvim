vim.pack.add({
  { src = 'https://github.com/AndrewRadev/switch.vim' },
})

vim.g.switch_custom_definitions = {
  { '> [!TODO]', '> [!WIP]', '> [!DONE]', '> [!FAIL]' },
  { '- [ ]', '- [>]', '- [x]' },
  { 'height', 'width' },
}
