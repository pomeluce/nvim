return {
  -- 翻译插件
  {
    'uga-rosa/translate.nvim',
    event = 'VeryLazy',
    opts = { default = { command = 'translate_shell' }, preset = { command = { translate_shell = { args = { '-e', 'bing' } } } } },
  },
}
