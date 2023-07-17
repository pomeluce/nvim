local M = {}

function M.config()
  -- 安装插件
  vim.g.coc_global_extensions = {
    '@yaegassy/coc-volar',
    '@yaegassy/coc-tailwindcss3',
    'coc-marketplace',
    'coc-css',
    'coc-clangd',
    'coc-db',
    'coc-eslint',
    'coc-git',
    'coc-html',
    'coc-json',
    'coc-pairs',
    'coc-prettier',
    'coc-pyright',
    'coc-rust-analyzer',
    'coc-sh',
    'coc-snippets',
    'coc-sumneko-lua',
    'coc-toml',
    'coc-translator',
    'coc-tsserver',
    'coc-vimlsp',
    'coc-word',
    'coc-yaml',
  }
  -- 添加 Fold 命令
  vim.api.nvim_create_user_command('Fold', "call CocAction('fold', <f-args>)", { nargs = '?' })
  -- 添加格式化
  vim.api.nvim_create_user_command('Format', "call CocAction('format')", {})
  -- 优化导包
  vim.api.nvim_create_user_command("OR", "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})
end

function M.setup()
  -- do nothing
end

return M
