return {
  cmd = { 'unocss-language-server', '--stdio' },
  root_dir = require('lspconfig.util').root_pattern('unocss.config.js', 'unocss.config.ts', 'uno.config.js', 'uno.config.ts'),
}
