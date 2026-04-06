---@type packman.SpecItem[]
return {
  {
    'esmuellert/codediff.nvim',
    cmd = 'CodeDiff',
    dependencies = { 'MunifTanjim/nui.nvim' },
    config = function()
      require('codediff').setup()
    end,
  },
}
