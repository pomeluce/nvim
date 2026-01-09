return {
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  single_file_support = true,
  settings = {
    css = {
      validate = true,
      lint = { unknownAtRules = 'ignore' },
    },
    scss = {
      validate = true,
      lint = { unknownAtRules = 'ignore' },
    },
    less = {
      validate = true,
      lint = { unknownAtRules = 'ignore' },
    },
  },
}
