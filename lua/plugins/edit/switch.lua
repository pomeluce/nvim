vim.g.switch_custom_definitions = {
  { '> [!TODO]', '> [!WIP]', '> [!DONE]', '> [!FAIL]' },
  { '- [ ]', '- [>]', '- [x]' },
  { 'height', 'width' },
}

---@type packman.SpecItem
return { 'AndrewRadev/switch.vim' }
