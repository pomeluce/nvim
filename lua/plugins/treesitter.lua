vim.pack.add({
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-context' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects', version = 'main' },
  { src = 'https://github.com/JoosepAlviste/nvim-ts-context-commentstring' },
})

local map = vim.keymap.set

local parsers = {
  'c',
  'cmake',
  'cpp',
  'css',
  'go',
  'java',
  'javascript',
  'json',
  'lua',
  'markdown',
  'markdown_inline',
  'python',
  'rust',
  'scss',
  'toml',
  'typescript',
  'tsx',
  'vue',
  'yaml',
}

vim.api.nvim_create_autocmd('BufReadPre', {
  group = vim.api.nvim_create_augroup('SetupTreesitter', { clear = true }),
  once = true,
  callback = function()
    local ts = require('nvim-treesitter')
    ts.install(parsers):wait(60 * 1000)

    require('nvim-treesitter-textobjects').setup({
      select = {
        -- 自动跳转到 textobj, 类似于 targets.vim
        lookahead = true,
        selection_modes = {
          ['@parameter.outer'] = 'v', -- charwise
          ['@function.outer'] = 'V', -- linewise
          ['@class.outer'] = '<c-v>', -- blockwise
        },
        -- 不选中多余的空格
        include_surrounding_whitespace = false,
      },
    })

    local function map_textobj(lhs, capture, query_group)
      map(
        { 'o', 'x' },
        lhs,
        function() require('nvim-treesitter-textobjects.select').select_textobject(capture, query_group or 'textobjects') end,
        { desc = 'Treesitter select: ' .. lhs }
      )
    end
    map_textobj('af', '@function.outer')
    map_textobj('if', '@function.inner')
    map_textobj('ac', '@class.outer')
    map_textobj('ic', '@class.inner')
    map_textobj('as', '@local.scope', 'locals')

    require('ts_context_commentstring').setup({})

    vim.cmd([[
      SetHL { ['@comment'] = { fg = '#868e96', italic = true } } 
    ]])

    -- require('treesitter-context').setup({
    --   separator = nil,
    --   max_lines = 5,
    --   multiwindow = true,
    --   min_window_height = 15,
    -- })
    -- vim.api.nvim_set_hl(0, 'TreesitterContext', { link = 'CursorLine' }) -- remove existing link
    -- vim.api.nvim_set_hl(0, 'TreesitterContextBottom', { underline = true, sp = '#b4befe' })
    -- vim.api.nvim_set_hl(0, "TreesitterContextBottom", { link = "CursorLine" }) -- remove existing link
  end,
})
