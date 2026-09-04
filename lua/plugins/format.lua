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

      local function find_upward_file(ctx, names)
        local dir = ctx.dirname
        while dir do
          for _, name in ipairs(names) do
            local path = vim.fs.joinpath(dir, name)
            if vim.fn.filereadable(path) == 1 then return path end
          end
          local parent = vim.fs.dirname(dir)
          if not parent or parent == dir then break end
          dir = parent
        end
        return nil
      end

      local function read_file(path)
        local ok, lines = pcall(vim.fn.readfile, path)
        if not ok then return nil end
        return table.concat(lines, '\n')
      end

      local function find_nearest_pom(ctx)
        local path = find_upward_file(ctx, { 'pom.xml' })
        return path
      end

      local function find_maven_wrapper(ctx)
        local names = vim.fn.has('win32') == 1 and { 'mvnw.cmd', 'mvnw' } or { 'mvnw' }
        local dir = ctx.dirname
        while dir do
          for _, name in ipairs(names) do
            local wrapper = vim.fs.joinpath(dir, name)
            if vim.fn.filereadable(wrapper) == 1 and (vim.fn.has('win32') == 1 or vim.fn.executable(wrapper) == 1) then return wrapper end
          end
          local parent = vim.fs.dirname(dir)
          if not parent or parent == dir then break end
          dir = parent
        end
        return nil
      end

      local function xml_element(content, name)
        if content:match('<' .. name .. '%s*/>') then return '' end
        return content:match('<' .. name .. '>%s*(.-)%s*</' .. name .. '>')
      end

      local function parent_pom(pom)
        local content = read_file(pom)
        if not content then return nil end
        local parent = content:match('<parent>%s*(.-)%s*</parent>')
        if not parent then return nil end

        ---@type string|nil
        local relative_path = xml_element(parent, 'relativePath')
        if relative_path == '' then return nil end
        relative_path = relative_path or '../pom.xml'
        local path = vim.fs.normalize(vim.fs.joinpath(vim.fs.dirname(pom), relative_path))
        return vim.fn.filereadable(path) == 1 and path or nil
      end

      local function find_spotless_maven(ctx)
        local module_pom = find_nearest_pom(ctx)
        if not module_pom then return nil end

        local visited = {}
        ---@type string|nil
        local pom = module_pom
        while pom and not visited[pom] do
          visited[pom] = true
          local content = read_file(pom)
          if content and (content:find('spotless%-maven%-plugin') or content:find('com%.diffplug%.spotless')) then return { module_pom = module_pom, pom = pom } end
          pom = parent_pom(pom)
        end
        return nil
      end

      local function spotless_formats_xml(content)
        local normalized = content:lower()
        if normalized:find('<xml[%s>]') then return true end
        local formats = content:match('<formats>%s*(.-)%s*</formats>')
        if not formats then return false end
        return formats:lower():find('%.xml') ~= nil
      end

      local function find_spotless_xml(ctx)
        local module_pom = find_nearest_pom(ctx)
        if not module_pom then return nil end

        local visited = {}
        ---@type string|nil
        local pom = module_pom
        local has_spotless_plugin = false
        local has_xml_format = false
        while pom and not visited[pom] do
          visited[pom] = true
          local content = read_file(pom)
          if content then
            has_spotless_plugin = has_spotless_plugin
              or content:find('spotless%-maven%-plugin') ~= nil
              or content:find('com%.diffplug%.spotless') ~= nil
            has_xml_format = has_xml_format or spotless_formats_xml(content)
          end
          if has_spotless_plugin and has_xml_format then
            return { module_pom = module_pom, pom = pom }
          end
          pom = parent_pom(pom)
        end
        return nil
      end

      local function has_spotless_gradle_config(ctx)
        local gradle_root_file = find_upward_file(ctx, { 'gradlew' })
        if not gradle_root_file then return false end
        local root = vim.fs.dirname(gradle_root_file)
        local dir = ctx.dirname
        while dir do
          for _, name in ipairs({ 'build.gradle', 'build.gradle.kts', 'settings.gradle', 'settings.gradle.kts', 'gradle/libs.versions.toml' }) do
            local path = vim.fs.joinpath(dir, name)
            if vim.fn.filereadable(path) == 1 then
              local ok, lines = pcall(vim.fn.readfile, path)
              if ok and string.find(table.concat(lines, '\n'), 'spotless') then return true end
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
      local default_rustfmt = require('conform.formatters.rustfmt')
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
          java = function(bufnr)
            local filename = vim.api.nvim_buf_get_name(bufnr)
            local dirname = filename ~= '' and vim.fs.dirname(filename) or nil
            if not dirname then return { 'clang-format' } end
            local ctx = { filename = filename, dirname = dirname, buf = bufnr }
            if find_spotless_maven(ctx) then return { 'spotless_maven' } end
            if has_spotless_gradle_config(ctx) then return { 'spotless_gradle' } end
            return { 'clang-format' }
          end,
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
          xml = function(bufnr)
            local filename = vim.api.nvim_buf_get_name(bufnr)
            local dirname = filename ~= '' and vim.fs.dirname(filename) or nil
            if not dirname then return { lsp_format = 'fallback' } end
            local ctx = { filename = filename, dirname = dirname, buf = bufnr }
            if find_spotless_xml(ctx) then return { 'spotless_maven' } end
            return { lsp_format = 'fallback' }
          end,
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
          spotless_gradle = {
            condition = function(_, ctx) return has_spotless_gradle_config(ctx) end,
          },
          spotless_maven = {
            condition = function(_, ctx) return find_spotless_maven(ctx) ~= nil end,
            command = function(_, ctx) return find_maven_wrapper(ctx) or 'mvn' end,
            cwd = function(_, ctx)
              local wrapper = find_maven_wrapper(ctx)
              if wrapper then return vim.fs.dirname(wrapper) end
              local module_pom = find_nearest_pom(ctx)
              return module_pom and vim.fs.dirname(module_pom) or nil
            end,
            args = function(self, ctx)
              local args = require('conform.formatters.spotless_maven').args(self, ctx)
              local maven = find_spotless_maven(ctx)
              if maven then
                table.insert(args, 1, maven.module_pom)
                table.insert(args, 1, '-f')
                table.insert(args, 3, '-N')
              end
              return args
            end,
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
