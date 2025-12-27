require('conform').setup {
  formatters_by_ft = {
    lua = { 'stylua' },
    css = { 'prettier' },
    html = { 'prettier' },
    javascript = { 'prettier' },
    javascriptreact = { 'prettier' },
    json = { 'prettier' },
    jsonc = { 'prettier' },
    markdown = { 'prettier' },
    nix = { 'nixfmt' },
    python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
    rust = { 'rustfmt' },
    scss = { 'prettier' },
    sh = { 'shfmt' },
    sql = { 'sqlfluff' },
    toml = { 'taplo' },
    typescript = { 'prettier' },
    typescriptreact = { 'prettier' },
    vue = { 'prettier' },
    yaml = { 'prettier' },
    zsh = { 'beautysh' },
  },

  formatters = {
    prettier = {
      command = 'prettier',
      args = function(ctx)
        local args = {
          '--stdin-filepath',
          '$FILENAME',
          '--config',
          vim.fn.expand(require('utils').cfg_path .. '/.prettierrc.json'),
        }

        -- 根据文件类型设置 parser(可选)
        local parser_map = {
          css = 'css',
          markdown = 'markdown',
          scss = 'scss',
          typescript = 'typescript',
          typescriptreact = 'typescript',
          yaml = 'yaml',
          vue = 'vue',
        }
        local parser = parser_map[ctx.filetype]
        if parser then
          table.insert(args, '--parser')
          table.insert(args, parser)
        end
        return args
      end,
      stdin = true,
      cwd = require('conform.util').root_file { '.prettierrc', 'package.json', '.git' },
    },

    stylua = {
      command = 'stylua',
      args = {
        '--stdin-filepath',
        '$FILENAME',
        '--config-path',
        vim.fn.expand(require('utils').cfg_path .. '/.stylua.toml'),
        '--',
        '-',
      },
      stdin = true,
    },

    nixfmt = {
      command = 'nixfmt',
      args = {},
      stdin = true,
    },

    rustfmt = {
      -- rules: https://rust-lang.github.io/rustfmt
      command = 'rustfmt',
      args = {
        '--config-path',
        vim.fn.expand(require('utils').cfg_path .. '/.rustfmt.toml'),
      },
      stdin = true,
    },

    shfmt = {
      command = 'shfmt',
      args = function()
        local shiftwidth = vim.opt.shiftwidth:get()
        local expandtab = vim.opt.expandtab:get()

        if not expandtab then
          shiftwidth = 0
        end

        return {
          '-i',
          shiftwidth,
        }
      end,
      stdin = true,
    },

    sqlfluff = {
      command = 'sqlfluff',
      args = {
        'format',
        '--config',
        vim.fn.expand(require('utils').cfg_path .. '/.sqlfluff.cfg'),
        '-',
      },
      stdin = true,
      require_cwd = false,
    },

    taplo = {
      command = 'taplo',
      args = {
        'fmt',
        '--stdin-filepath',
        '$FILENAME',
        '-',
        '--config',
        vim.fn.expand(require('utils').cfg_path .. '/.taplo.toml'),
      },
      stdin = true,
    },

    beautysh = {
      command = 'beautysh',
      args = function()
        local shiftwidth = vim.opt.shiftwidth:get()
        local expandtab = vim.opt.expandtab:get()
        if not expandtab then
          shiftwidth = 0
        end

        return {
          '-i',
          shiftwidth,
          '$FILENAME',
        }
      end,
      stdin = false,
    },
  },
}
