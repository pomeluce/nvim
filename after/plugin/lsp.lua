local enable = require('utils').lsp_enable

vim.lsp.enable('copilot')

enable('python', 'basedpyright')
enable({ 'sh', 'zsh' }, 'bashls')
enable({ 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' }, 'clangd')
enable('cmake', 'cmake')
enable({ 'css', 'scss', 'less' }, 'cssls')
enable({ 'astro', 'css', 'eruby', 'html', 'htmldjango', 'javascriptreact', 'less', 'sass', 'scss', 'svelte', 'typescriptreact', 'vue' }, 'emmet_language_server')
enable('html', 'html')
enable({ 'json', 'jsonc' }, 'jsonls')
enable('kotlin', 'kotlin_language_server')
enable('lua', 'lua_ls')
enable('nix', 'nil_ls')
enable('rust', 'rust_analyzer')
enable({
  'astro',
  'clojure',
  'htmldjango',
  'elixir',
  'eruby',
  'haml',
  'html',
  'htmlangular',
  'heex',
  'liquid',
  'markdown',
  'php',
  'twig',
  'css',
  'less',
  'sass',
  'scss',
  'stylus',
  'javascript',
  'javascriptreact',
  'rescript',
  'typescript',
  'typescriptreact',
  'vue',
  'svelte',
}, 'tailwindcss')
enable('toml', 'taplo')
enable({ 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' }, { 'ts_ls', 'vue_ls' })
enable('vue', 'vue_ls')
