return {
  settings = {
    ['rust-analyzer'] = {
      imports = { granularity = { group = 'module' }, prefix = 'self' },
      cargo = { buildScripts = { enable = true } },
      check = { command = 'clippy' },
      procMacro = { enable = true },
    },
  },
}
