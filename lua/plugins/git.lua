vim.pack.add({
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },
})

vim.api.nvim_create_autocmd('UIEnter', {
  group = vim.api.nvim_create_augroup('SetupGit', { clear = true }),
  callback = function()
    require('gitsigns').setup({
      signs = {
        add = { text = '┃' },
        change = { text = '┃' },
        delete = { text = '▁' },
        topdelete = { text = '▔' },
        changedelete = { text = '≃' },
        untracked = { text = '┆' },
      },
      signcolumn = true, -- 使用 `:Gitsigns toggle_signs` 切换
      numhl = false, -- 使用 `:Gitsigns toggle_numhl` 切换
      linehl = false, -- 使用 `:Gitsigns toggle_linehl` 切换
      word_diff = false, -- 使用 `:Gitsigns toggle_word_diff` 切换
      watch_gitdir = { interval = 1000, follow_files = true },
      attach_to_untracked = true,
      current_line_blame = true, -- 使用 `:Gitsigns toggle_current_line_blame` 切换
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil, -- 使用默认
      max_file_length = 40000, -- 如果文件行数超过此数量则禁用
      -- 传递给 nvim_open_win 的选项
      preview_config = { border = 'rounded', style = 'minimal', relative = 'cursor', row = 0, col = 1 },
    })
  end,
})
