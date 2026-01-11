---@type vim.lsp.Config
return {
  cmd = { 'tailwindcss-language-server', '--stdio' },
  settings = {
    -- config params: https://github.com/tailwindlabs/tailwindcss-intellisense#extension-settings
    tailwindCSS = {
      classAttributes = { 'class', 'className', 'class:list', 'classList', 'ngClass' },
      includeLanguages = { eelixir = 'html-eex', eruby = 'erb', htmlangular = 'html', templ = 'html' },
      lint = {
        cssConflict = 'warning',
        invalidApply = 'error',
        invalidConfigPath = 'error',
        invalidScreen = 'error',
        invalidTailwindDirective = 'error',
        invalidVariant = 'error',
        recommendedVariantOrder = 'warning',
      },
      validate = true,
    },
  },
}
