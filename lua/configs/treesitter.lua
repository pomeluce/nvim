pcall(function()
  dofile(vim.g.base46_cache .. 'syntax')
  dofile(vim.g.base46_cache .. 'treesitter')
end)

-- local ts = require('nvim-treesitter')
--
-- -- state tracking
-- local parsers_loaded = {}
-- local parsers_failed = {}
-- local parsers_pending = {} ---@type table<number, string> -- buf -> lang
--
-- local ns = vim.api.nvim_create_namespace('treesitter.async')
--
-- local function start(buf, lang)
--   if not vim.api.nvim_buf_is_valid(buf) then
--     return false
--   end
--
--   local ok = pcall(vim.treesitter.start, buf, lang)
--   if not ok then
--     return false
--   end
--
--   vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
--   vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
--   vim.wo.foldmethod = 'expr'
--   vim.wo.foldlevel = 99
--
--   return true
-- end
--
-- -- install core parsers after Lazy finished
-- vim.api.nvim_create_autocmd('User', {
--   pattern = 'LazyDone',
--   once = true,
--   callback = function()
--     ts.install({
--       'c',
--       'cmake',
--       'cpp',
--       'css',
--       'go',
--       'java',
--       'javascript',
--       'json',
--       'jsx',
--       'lua',
--       'markdown',
--       'markdown_inline',
--       'python',
--       'rust',
--       'scss',
--       'toml',
--       'tsx',
--       'typescript',
--       'vue',
--       'yaml',
--     }, { max_jobs = 8 })
--   end,
-- })
--
-- -- decoration provider: async start parsers
-- vim.api.nvim_set_decoration_provider(ns, {
--   on_start = vim.schedule_wrap(function()
--     if next(parsers_pending) == nil then
--       return false
--     end
--
--     for buf, lang in pairs(parsers_pending) do
--       if not parsers_failed[lang] then
--         if start(buf, lang) then
--           parsers_loaded[lang] = true
--         else
--           parsers_failed[lang] = true
--         end
--       end
--     end
--
--     parsers_pending = {}
--     return false
--   end),
-- })
--
-- -- filetype autocmd
-- local group = vim.api.nvim_create_augroup('TreesitterSetup', { clear = true })
-- local ignore_filetypes = { checkhealth = true, lazy = true, mason = true, snacks_dashboard = true, snacks_notif = true, snacks_win = true }
--
-- vim.api.nvim_create_autocmd('FileType', {
--   group = group,
--   desc = 'Enable treesitter highlighting & indent (async)',
--   callback = function(event)
--     local ft = vim.filetype.match { buf = event.buf } or event.match
--     if ignore_filetypes[ft] then
--       return
--     end
--
--     local lang = vim.treesitter.language.get_lang(ft)
--     if not lang then
--       return
--     end
--
--     local buf = event.buf
--
--     if parsers_failed[lang] then
--       return
--     end
--
--     -- fast path
--     if parsers_loaded[lang] then
--       start(buf, lang)
--       return
--     end
--
--     -- queue for async start (deduplicated by buf)
--     parsers_pending[buf] = lang
--
--     -- install parser if missing (no-op if already installed)
--     ts.install { lang }
--   end,
-- })
--
-- require('nvim-treesitter-textobjects').setup {
--   select = {
--     -- automatically jump forward to textobj, similar to targets.vim
--     lookahead = true,
--     selection_modes = {
--       ['@parameter.outer'] = 'v', -- charwise
--       ['@function.outer'] = 'V', -- linewise
--       ['@class.outer'] = '<c-v>', -- blockwise
--     },
--     -- 不选中多余的空格
--     include_surrounding_whitespace = false,
--   },
-- }
-- local select = require('nvim-treesitter-textobjects.select')
-- local function map_textobj(lhs, capture, query_group)
--   vim.keymap.set({ 'o', 'x' }, lhs, function()
--     select.select_textobject(capture, query_group or 'textobjects')
--   end, { desc = 'treesitter select ' .. lhs })
-- end
--
-- map_textobj('af', '@function.outer')
-- map_textobj('if', '@function.inner')
-- map_textobj('ac', '@class.outer')
-- map_textobj('ic', '@class.inner')
-- map_textobj('as', '@local.scope', 'locals')

require('nvim-treesitter.configs').setup {
  -- 安装常用解析器
  ensure_installed = {
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
  },
  --开启高亮
  highlight = {
    enable = true,
  },
  -- 更好的代码格式化
  indent = {
    enable = true,
  },
  -- textobjects
  textobjects = {
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        -- You can optionally set descriptions to the mappings (used in the desc parameter of
        -- nvim_buf_set_keymap) which plugins like which-key display
        ['ic'] = { query = '@class.inner', desc = 'Select inner part of a class region' },
        -- You can also use captures from other query groups like `locals.scm`
        ['as'] = { query = '@scope', query_group = 'locals', desc = 'Select language scope' },
      },
      -- You can choose the select mode (default is charwise 'v')
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * method: eg 'v' or 'o'
      -- and should return the mode ('v', 'V', or '<c-v>') or a table
      -- mapping query_strings to modes.
      selection_modes = {
        ['@parameter.outer'] = 'v', -- charwise
        ['@function.outer'] = 'V', -- linewise
        ['@class.outer'] = '<c-v>', -- blockwise
      },
      -- 不选中多余的空格
      include_surrounding_whitespace = false,
    },
    context_commentstring = {
      enable = true,
    },
  },
}

local function bootstrap()
  local parsers = require('nvim-treesitter.parsers')
  local lang = parsers.ft_to_lang(vim.api.nvim_eval('&ft'))
  local has_parser = parsers.has_parser(lang)
  if not has_parser then
    vim.api.nvim_command("try | call execute('TSInstall " .. lang .. "') | catch | endtry")
  end
  vim.cmd([[
    SetHL { ['@comment'] = { fg = '#868e96', italic = true } } 
  ]])
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter', { clear = true }),
  pattern = '*',
  callback = function()
    bootstrap()
  end,
})

bootstrap()
