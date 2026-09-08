local sql = require('plugins.format.sql')
sql.setup()

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
  once = true,
  callback = function()
    PackUtils.load({ name = 'conform.nvim' }, function()
      local function root_file(files, bufnr)
        bufnr = bufnr or 0
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name == '' then return false end
        local dir = vim.fs.dirname(name)
        if not dir then return false end
        return vim.fs.root(dir, files) ~= nil
      end

      local conform = require('conform')
      local default_rustfmt = require('conform.formatters.rustfmt')
      local spotless = require('plugins.format.spotless').spec()
      local cfg = vim.fn.stdpath('config') .. '/lua/configs/fmt'

      local function format_after_save(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat or vim.b[bufnr].format_in_progress then return end
        vim.b[bufnr].format_in_progress = true
        return { lsp_format = 'fallback' }, function()
          if vim.api.nvim_buf_is_valid(bufnr) then vim.b[bufnr].format_in_progress = false end
        end
      end

      conform.setup({
        formatters_by_ft = {
          lua = { 'stylua' },
          css = { 'prettierd' },
          dockerfile = { 'dockerfmt' },
          html = { 'prettierd' },
          http = { 'kulala-fmt' },
          java = spotless.by_ft.java,
          javascript = { 'prettierd' },
          javascriptreact = { 'prettierd' },
          json = { 'prettierd' },
          jsonc = { 'prettierd' },
          markdown = { 'prettierd', 'cbfmt' },
          nix = { 'nixfmt' },
          nu = { 'nufmt' },
          python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
          rust = { 'rustfmt' },
          scss = { 'prettierd' },
          sh = { 'shfmt' },
          sql = { 'sqlfluff' },
          toml = { 'taplo' },
          typescript = { 'prettierd' },
          typescriptreact = { 'prettierd' },
          vue = { 'prettierd' },
          xml = spotless.by_ft.xml,
          yaml = { 'prettierd' },
          zsh = { 'beautysh' },
          ['_'] = { 'trim_whitespace' },
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
          cbfmt = { command = 'cbfmt', args = { '-w', '--config', vim.fn.expand(cfg .. '/cbfmt.toml'), '$FILENAME' } },
          ['clang-format'] = {
            args = function(_, ctx)
              local args = { '-assume-filename', '$FILENAME' }
              if not root_file({ '.clang-format', '_clang-format' }, ctx.buf) then vim.list_extend(args, { '-style=file:' .. vim.fn.expand(cfg .. '/java.clang-format') }) end
              return args
            end,
          },
          nixfmt = { command = 'nixfmt', args = {}, stdin = true },
          prettierd = vim.tbl_deep_extend('force', require('conform.formatters.prettierd'), { env = { PRETTIERD_DEFAULT_CONFIG = vim.fn.expand(cfg .. '/prettierrc.json') } }),
          rustfmt = {
            args = function(self, ctx)
              local args = default_rustfmt.args(self, ctx)
              local project_config = vim.fs.find({ 'rustfmt.toml', '.rustfmt.toml' }, { path = ctx.dirname, upward = true })[1]
              vim.list_extend(args, { '--config-path', project_config or vim.fn.expand(cfg .. '/rustfmt.toml') })
              return args
            end,
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
          spotless_gradle = spotless.formatters.spotless_gradle,
          spotless_maven = spotless.formatters.spotless_maven,
          sqlfluff = sql.formatter(cfg),
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
              return has_root and { 'fmt', '--stdin-filepath', '$FILENAME', '-' }
                or { 'fmt', '--stdin-filepath', '$FILENAME', '-', '--config', vim.fn.expand(cfg .. '/taplo.toml') }
            end,
            stdin = true,
          },
        },
        format_after_save = format_after_save,
      })
      vim.api.nvim_create_user_command('Format', function()
        local bufnr = vim.api.nvim_get_current_buf()
        if vim.b[bufnr].format_in_progress then return end
        vim.b[bufnr].format_in_progress = true
        conform.format({ async = true, bufnr = bufnr }, function()
          if vim.api.nvim_buf_is_valid(bufnr) then vim.b[bufnr].format_in_progress = false end
        end)
      end, { desc = 'Format command' })
      vim.api.nvim_create_user_command('FormatDisable', function(args)
        if args.bang then
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, { desc = 'Disable autoformat-on-save', bang = true })
      vim.api.nvim_create_user_command('FormatEnable', function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, { desc = 'Re-enable autoformat-on-save' })
      vim.api.nvim_create_autocmd('BufWritePre', {
        callback = function(args)
          local formatters = conform.list_formatters_for_buffer(args.buf)
          local real_formatter = false
          for _, f in ipairs(formatters) do
            if f.name ~= 'trim_whitespace' then
              real_formatter = true
              break
            end
          end
          local lsp_formatter = not vim.tbl_isempty(vim.lsp.get_clients({ bufnr = args.buf, method = 'textDocument/formatting' }))
          if not real_formatter and not lsp_formatter then
            local view = vim.fn.winsaveview()
            vim.cmd('silent! normal! gg=G')
            vim.fn.winrestview(view)
          end
        end,
      })
    end)
  end,
})
