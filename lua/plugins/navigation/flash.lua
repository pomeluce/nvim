---@type packman.SpecItem[]
return {
  {
    'folke/flash.nvim',
    event = 'VimEnter',
    opts = { modes = { char = { enabled = false } } },
  },
}
