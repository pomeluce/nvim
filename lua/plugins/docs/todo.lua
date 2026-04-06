---@type packman.SpecItem[]
return {
  {
    'folke/todo-comments.nvim',
    event = { 'BufEnter', 'BufWinEnter' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('todo-comments').setup({
        signs = true,
        sign_priority = 8,
        keywords = {
          FIX = { icon = ' ', color = 'error', alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' } },
          TODO = { icon = ' ', color = 'todo' },
          HACK = { icon = ' ', color = 'warning' },
          WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX' } },
          PERF = { icon = ' ', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
          NOTE = { icon = ' ', color = 'hint', alt = { 'INFO', 'TIP' } },
          TEST = { icon = '󰙨', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
        },
        gui_style = { fg = 'NONE', bg = 'BOLD' },
        merge_keywords = true,
        highlight = {
          multiline = true,
          multiline_pattern = '^.',
          multiline_context = 10,
          before = '',
          keyword = 'wide',
          after = 'fg',
          pattern = [[.*<(KEYWORDS)\s*:]],
          comments_only = true,
          max_line_len = 400,
          exclude = {},
        },
        colors = { error = { '#dc2626' }, warning = { '#fbbf24' }, todo = { '#a2e57b' }, hint = { '#f06595' }, default = { '#7c3aed' }, test = { '#2563eb' } },
        search = {
          command = 'rg',
          args = { '--color=never', '--no-heading', '--with-filename', '--line-number', '--column' },
          pattern = [[\b(KEYWORDS):]],
        },
      })
    end,
  },
}
