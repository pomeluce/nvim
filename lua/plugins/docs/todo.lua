vim.pack.add({
  { src = 'https://github.com/folke/todo-comments.nvim' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
})

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  group = vim.api.nvim_create_augroup('SetupTodoComments', { clear = true }),
  once = true,
  callback = function()
    require('todo-comments').setup({
      -- show icons in the signs column
      signs = true,
      -- sign priority
      sign_priority = 8,
      -- keywords recognized as todo comments
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
      -- when true, custom keywords will be merged with the defaults
      merge_keywords = true,

      -- highlighting of the line containing the todo comment
      -- * before: highlights before the keyword (typically comment characters)
      -- * keyword: highlights of the keyword
      -- * after: highlights after the keyword (todo text)
      highlight = {
        multiline = true, -- enable multine todo comments
        multiline_pattern = '^.', -- lua pattern to match the next multiline from the start of the matched keyword
        multiline_context = 10, -- extra lines that will be re-evaluated when changing a line
        before = '', -- "fg" or "bg" or empty
        keyword = 'wide', -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
        after = 'fg', -- "fg" or "bg" or empty
        pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
        comments_only = true, -- uses treesitter to match keywords in comments only
        max_line_len = 400, -- ignore lines longer than this
        exclude = {}, -- list of file types to exclude highlighting
      },
      colors = { error = { '#dc2626' }, warning = { '#fbbf24' }, todo = { '#a2e57b' }, hint = { '#f06595' }, default = { '#7c3aed' }, test = { '#2563eb' } },
      search = {
        command = 'rg',
        args = {
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
        },
        -- regex that will be used to match keywords.
        -- don't replace the (KEYWORDS) placeholder
        pattern = [[\b(KEYWORDS):]], -- ripgrep regex
        -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
      },
    })
  end,
})
