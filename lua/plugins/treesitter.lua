vim.pack.add({
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-context' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects', version = 'main' },
  { src = 'https://github.com/JoosepAlviste/nvim-ts-context-commentstring' },
})

local map = vim.keymap.set
---@param lhs string
---@param capture string
---@param query_group? string
local function map_textobj(lhs, capture, query_group)
  local function _rhs() require('nvim-treesitter-textobjects.select').select_textobject(capture, query_group or 'textobjects') end
  map({ 'o', 'x' }, lhs, _rhs, { desc = 'Treesitter select: ' .. lhs })
end

local ensure_installed = {
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
    ts.install(ensure_installed)

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
    map_textobj('af', '@function.outer')
    map_textobj('if', '@function.inner')
    map_textobj('ac', '@class.outer')
    map_textobj('ic', '@class.inner')
    map_textobj('as', '@local.scope', 'locals')

    require('ts_context_commentstring').setup({})

    vim.cmd([[ SetHL { ['@comment'] = { fg = '#868e96', italic = true } } ]])

    require('treesitter-context').setup({ separator = nil, max_lines = 5, multiwindow = true, min_window_height = 15 })
  end,
})

-- 自动安装 treesitter
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('AutoInstallTreesitter', { clear = true }),
  callback = function(event)
    local ok, nvim_treesitter = pcall(require, 'nvim-treesitter')
    if not ok then return end

    local parsers = require('nvim-treesitter.parsers')
    if not parsers[event.match] or not nvim_treesitter.install then return end

    local ft = vim.bo[event.buf].ft
    local lang = vim.treesitter.language.get_lang(ft)

    nvim_treesitter.install({ lang }):await(function(err)
      if err then
        vim.notify('Treesitter install error for ft: ' .. ft .. ' err: ' .. err)
        return
      end
      pcall(vim.treesitter.start, event.buf)
    end)
  end,
})
