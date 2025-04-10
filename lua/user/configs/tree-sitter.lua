local M = {}
local command = vim.api.nvim_command

function M.config()
  -- do nothing
end

function M.parser_bootstrap()
  local parsers = require('nvim-treesitter.parsers')
  local lang = parsers.ft_to_lang(vim.api.nvim_eval('&ft'))
  local has_parser = parsers.has_parser(lang)
  if not has_parser then
    command("try | call execute('TSInstall " .. lang .. "') | catch | endtry")
  end

  local util = require('user.core.funcutil')
  util.hl {
    ['@comment'] = { fg = '#868e96', italic = true },
  }
end

function M.setup()
  pcall(function()
    dofile(vim.g.base46_cache .. 'syntax')
    dofile(vim.g.base46_cache .. 'treesitter')
  end)

  return {
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
end

return M
