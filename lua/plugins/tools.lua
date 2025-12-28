return {
  -- 翻译插件
  {
    'uga-rosa/translate.nvim',
    event = 'VeryLazy',
    init = function()
      -- 目标语言
      vim.g.translator_target_lang = 'zh'
      -- 源语言
      vim.g.translator_source_lang = 'auto'
      -- 翻译引擎
      vim.g.translator_default_engines = { 'google' }
      -- 边框
      vim.g.translator_window_borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' }
    end,
  },
}
