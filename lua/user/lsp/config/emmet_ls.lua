return {
  cmd = { 'emmet-ls', '--stdio' },
  filetypes = { 'astro', 'css', 'eruby', 'html', 'htmldjango', 'javascriptreact', 'less', 'pug', 'sass', 'scss', 'svelte', 'typescriptreact', 'vue' },
  root_dir = require('lspconfig.util').root_pattern('package.json', '.git'),
  single_file_support = true,
  init_options = {
    html = {
      options = {
        -- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
        ['bem.enabled'] = true,
      },
    },
  },
}
