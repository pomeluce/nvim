---@type packman.SpecItem[]
return {
  {
    'uga-rosa/translate.nvim',
    event = 'VimEnter',
    opts = {
      default = { command = 'translate_shell' },
      preset = { command = { translate_shell = { args = { '-e', 'bing' } } } },
    },
  },
}
