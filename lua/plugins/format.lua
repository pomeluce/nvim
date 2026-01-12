vim.pack.add({
  { src = 'https://github.com/stevearc/conform.nvim' },
})

local function root_file(files, bufnr)
  bufnr = bufnr or 0
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == '' then return false end
  local dir = vim.fs.dirname(name)
  if not dir then return false end
  return vim.fs.root(dir, files) ~= nil
end

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufCreate' }, {
  group = vim.api.nvim_create_augroup('SetupFormat', { clear = true }),
  once = true,
  callback = function()
    local utils = require('utils')
    local cfg = vim.fn.stdpath('config') .. '/lua/configs/fmt'

    require('conform').setup({
      formatters_by_ft = {
        lua = { 'stylua' },
        css = { 'prettierd' },
        html = { 'prettierd' },
        javascript = { 'prettierd' },
        javascriptreact = { 'prettierd' },
        json = { 'prettierd' },
        jsonc = { 'prettierd' },
        markdown = { 'prettierd', 'cbfmt' },
        nix = { 'nixfmt' },
        python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
        rust = { 'rustfmt' },
        scss = { 'prettierd' },
        sh = { 'shfmt' },
        sql = { 'sqlfluff' },
        toml = { 'taplo' },
        typescript = { 'prettierd' },
        typescriptreact = { 'prettierd' },
        vue = { 'prettierd' },
        yaml = { 'prettierd' },
        zsh = { 'beautysh' },
      },
      formatters = {
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
        cbfmt = {
          command = 'cbfmt',
          args = { '-w', '--config', vim.fn.expand(cfg .. '/cbfmt.toml'), '$FILENAME' },
        },
        nixfmt = {
          command = 'nixfmt',
          args = {},
          stdin = true,
        },
        prettierd = {
          command = 'prettierd',
          args = function()
            local has_root = root_file({ '.prettierrc', '.prettierrc.json', '.prettierrc.js', '.prettierrc.cjs' })
            local args = { '--stdin-filepath', '$FILENAME' }

            if not has_root then
              table.insert(args, '--config')
              table.insert(args, vim.fn.expand(cfg .. '/prettierrc.json'))
            end

            return args
          end,
          stdin = true,
          cwd = function(_, ctx)
            return vim.fs.root(ctx.dirname, function(name, path)
              if
                vim.tbl_contains({
                  -- https://prettier.io/docs/en/configuration.html
                  '.prettierrc',
                  '.prettierrc.json',
                  '.prettierrc.yml',
                  '.prettierrc.yaml',
                  '.prettierrc.json5',
                  '.prettierrc.js',
                  '.prettierrc.cjs',
                  '.prettierrc.mjs',
                  '.prettierrc.toml',
                  'prettier.config.js',
                  'prettier.config.cjs',
                  'prettier.config.mjs',
                }, name)
              then
                return true
              end

              if name == 'package.json' then
                local full_path = vim.fs.joinpath(path, name)
                local package_data = utils.read_json(full_path)
                return package_data and package_data.prettier and true or false
              end
              return false
            end)
          end,
        },
        rustfmt = {
          -- rules: https://rust-lang.github.io/rustfmt
          command = 'rustfmt',
          args = function()
            local has_root = root_file({ '.rustfmt.toml', 'rustfmt.toml' })
            return has_root and {} or { '--config-path', vim.fn.expand(cfg .. '/rustfmt.toml') }
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
            return has_root and { 'format', '-' } or { 'format', '--config', vim.fn.expand(cfg .. '/sqlfluff.cfg'), '-' }
          end,
          stdin = true,
          require_cwd = false,
        },
        stylua = {
          command = 'stylua',
          args = function()
            local has_root = root_file({ '.stylua.toml', 'stylua.toml' })
            return has_root and { '--stdin-filepath', '$FILENAME', '--', '-' }
              or { '--stdin-filepath', '$FILENAME', '--config-path', vim.fn.expand(cfg .. '/stylua.toml'), '--', '-' }
          end,
          stdin = true,
        },
        taplo = {
          command = 'taplo',
          args = function()
            local has_root = root_file({ '.taplo.toml', 'taplo.toml' })
            return has_root and { 'fmt', '--stdin-filepath', '$FILENAME', '-' } or { 'fmt', '--stdin-filepath', '$FILENAME', '-', '--config', vim.fn.expand(cfg .. '/taplo.toml') }
          end,
          stdin = true,
        },
      },
      format_on_save = function(bufnr)
        -- 使用全局变量或缓冲区本地变量禁用
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
        return { timeout_ms = 500, lsp_format = 'fallback' }
      end,
    })
    vim.api.nvim_create_user_command('Format', function() require('conform').format({ async = true }) end, { desc = 'Format command' })
    vim.api.nvim_create_user_command('FormatDisable', function(args)
      if args.bang then
        -- FormatDisable! 将仅对这个缓冲区禁用格式化
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end, { desc = 'Disable autoformat-on-save', bang = true })
    vim.api.nvim_create_user_command('FormatEnable', function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, { desc = 'Re-enable autoformat-on-save' })
  end,
})
