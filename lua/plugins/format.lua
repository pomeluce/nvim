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

      local function project_file_contains(root_files, config_files, pattern, ctx)
        local root = vim.fs.root(ctx.dirname, root_files)
        if not root then return false end

        local dir = ctx.dirname
        while dir do
          for _, name in ipairs(config_files) do
            local path = vim.fs.joinpath(dir, name)
            if vim.fn.filereadable(path) == 1 then
              local ok, lines = pcall(vim.fn.readfile, path)
              if ok and string.find(table.concat(lines, '\n'), pattern) then return true end
            end
          end
          if dir == root then break end
          local parent = vim.fs.dirname(dir)
          if not parent or parent == dir then break end
          dir = parent
        end
        return false
      end

      local conform = require('conform')
      local cfg = vim.fn.stdpath('config') .. '/lua/configs/fmt'

      conform.setup({
        formatters_by_ft = {
          lua = { 'stylua' },
          css = { 'prettierd' },
          dockerfile = { 'dockerfmt' },
          html = { 'prettierd' },
          http = { 'kulala-fmt' },
          java = { 'spotless_gradle', 'spotless_maven', 'clang-format', stop_after_first = true },
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
          xml = { lsp_format = 'fallback' },
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
          spotless_gradle = {
            condition = function(_, ctx)
              return project_file_contains(
                { 'gradlew' },
                { 'build.gradle', 'build.gradle.kts', 'settings.gradle', 'settings.gradle.kts', 'gradle/libs.versions.toml' },
                'spotless',
                ctx
              )
            end,
          },
          spotless_maven = {
            condition = function(_, ctx) return project_file_contains({ 'mvnw' }, { 'pom.xml' }, 'spotless', ctx) end,
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
              return has_root and { 'fmt', '--stdin-filepath', '$FILENAME', '-' }
                or { 'fmt', '--stdin-filepath', '$FILENAME', '-', '--config', vim.fn.expand(cfg .. '/taplo.toml') }
            end,
            stdin = true,
          },
        },
        format_after_save = function(bufnr)
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
          return { lsp_format = 'fallback' }
        end,
      })
      vim.api.nvim_create_user_command('Format', function() conform.format({ async = true }) end, { desc = 'Format command' })
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
