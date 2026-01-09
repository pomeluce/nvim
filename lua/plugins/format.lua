vim.pack.add({
  { src = 'https://github.com/stevearc/conform.nvim' },
})

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufCreate' }, {
  group = vim.api.nvim_create_augroup('SetupFormat', { clear = true }),
  once = true,
  callback = function()
    local util = require('conform.util')
    local cfg = vim.fn.stdpath('config')

    local function root_file(files, bufnr)
      bufnr = bufnr or 0

      local name = vim.api.nvim_buf_get_name(bufnr)
      if name == '' then return false end

      local dir = vim.fs.dirname(name)
      if not dir then return false end

      return vim.fs.root(dir, files) ~= nil
    end

    require('conform').setup({
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
            local has_root = root_file({ '.prettierrc', '.prettierrc.json', '.prettierrc.js', '.prettierrc.cjs' })
            local args = { '--stdin-filepath', '$FILENAME' }

            if not has_root then
              table.insert(args, '--config')
              table.insert(args, vim.fn.expand(cfg .. '/.prettierrc.json'))
            end

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
          cwd = util.root_file({ '.prettierrc', '.prettierrc.json', 'package.json', '.git' }),
        },

        stylua = {
          command = 'stylua',
          args = function()
            local has_root = root_file({ '.stylua.toml', 'stylua.toml' })
            return has_root and { '--stdin-filepath', '$FILENAME', '--', '-' }
              or { '--stdin-filepath', '$FILENAME', '--config-path', vim.fn.expand(cfg .. '/.stylua.toml'), '--', '-' }
          end,
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
          args = function()
            local has_root = root_file({ '.rustfmt.toml', 'rustfmt.toml' })
            return has_root and {} or { '--config-path', vim.fn.expand(cfg .. '/.rustfmt.toml') }
          end,
          stdin = true,
        },

        shfmt = {
          command = 'shfmt',
          args = function()
            local shiftwidth = vim.opt.shiftwidth:get()
            local expandtab = vim.opt.expandtab:get()

            if not expandtab then shiftwidth = 0 end

            return { '-i', shiftwidth }
          end,
          stdin = true,
        },

        sqlfluff = {
          command = 'sqlfluff',
          args = function()
            local has_root = root_file({ '.sqlfluff', 'sqlfluff.cfg' })
            return has_root and { 'format', '-' } or { 'format', '--config', vim.fn.expand(cfg .. '/.sqlfluff.cfg'), '-' }
          end,
          stdin = true,
          require_cwd = false,
        },

        taplo = {
          command = 'taplo',
          args = function()
            local has_root = root_file({ '.taplo.toml', 'taplo.toml' })
            return has_root and { 'fmt', '--stdin-filepath', '$FILENAME', '-' } or { 'fmt', '--stdin-filepath', '$FILENAME', '-', '--config', vim.fn.expand(cfg .. '/.taplo.toml') }
          end,
          stdin = true,
        },

        beautysh = {
          command = 'beautysh',
          args = function()
            local shiftwidth = vim.opt.shiftwidth:get()
            local expandtab = vim.opt.expandtab:get()
            if not expandtab then shiftwidth = 0 end

            return { '-i', shiftwidth, '$FILENAME' }
          end,
          stdin = false,
        },
      },
    })
    vim.api.nvim_create_user_command('Format', function() require('conform').format({ async = true }) end, { desc = 'Format command' })
  end,
})
