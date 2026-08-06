local map = vim.keymap.set
local bufnr = vim.api.nvim_get_current_buf()
local bufname = vim.api.nvim_buf_get_name(bufnr)

-- jdtls class files are transient views, not project source buffers.
if vim.startswith(bufname, 'jdt://') then
  local origin = require('configs.java').take_definition_origin(vim.api.nvim_get_current_tabpage())
  vim.b[bufnr].transient = true
  if type(origin) == 'number' and vim.api.nvim_buf_is_valid(origin) then vim.b[bufnr].transient_origin = origin end
  vim.bo[bufnr].buflisted = false
  vim.bo[bufnr].bufhidden = 'wipe'
  vim.bo[bufnr].swapfile = false
  return
end

PackUtils.load({ name = 'nvim-jdtls' })
if vim.fn.executable('jdtls') ~= 1 then
  vim.notify_once('jdtls is not executable; Java LSP support is disabled', vim.log.levels.WARN)
  return
end

local markers = {
  '.git',
  'mvnw',
  'gradlew',
  'pom.xml',
  'settings.gradle',
  'settings.gradle.kts',
  'build.gradle',
  'build.gradle.kts',
}
local root_dir = vim.fs.root(bufnr, markers) or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
local java = require('configs.java').setup(root_dir)
local jdtls = require('jdtls')

map('n', 'gd', function()
  local origin = vim.api.nvim_get_current_buf()
  local params = vim.lsp.util.make_position_params(0, 'utf-8')
  vim.lsp.buf_request(0, 'textDocument/definition', params, function(_, result)
    if not result or vim.tbl_isempty(result) then
      vim.notify('No definition found', vim.log.levels.INFO)
      return
    end
    require('configs.java').set_definition_origin(vim.api.nvim_get_current_tabpage(), origin)
    Snacks.picker.lsp_definitions()
  end)
end, { buffer = bufnr, desc = 'Java: Goto definition' })

local function command(name, callback, description)
  pcall(vim.api.nvim_buf_del_user_command, bufnr, name)
  vim.api.nvim_buf_create_user_command(bufnr, name, callback, { desc = description })
end

command('JavaCompile', function()
  jdtls.compile('full', function(items)
    if not items or #items == 0 then return end
    vim.schedule(function()
      vim.cmd('botright copen')
      for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buffer].buftype == 'quickfix' then vim.bo[buffer].buflisted = false end
      end
    end)
  end)
end, 'Build Java workspace')
command('JavaUpdateConfig', jdtls.update_project_config, 'Update Maven/Gradle project config')
command('JavaOrganizeImports', jdtls.organize_imports, 'Organize Java imports')
command('JavaRunMain', function() java.runner:start() end, 'Run a Java main class')
command('JavaStopMain', function() java.runner:stop() end, 'Stop the running Java main class')
command('JavaToggleLogs', function() java.runner:toggle() end, 'Toggle Java run output')
command('JavaDebugMain', function()
  if not java.has_debug then
    vim.notify('VSC_JAVA_DEBUG is not configured or contains no debug bundle', vim.log.levels.ERROR)
    return
  end
  require('jdtls.dap').setup_dap_main_class_configs({
    verbose = true,
    on_ready = function(configs)
      if #configs > 0 then
        require('dap').continue()
      else
        vim.notify('No main class found', vim.log.levels.ERROR)
      end
    end,
  })
end, 'Debug a Java main class')
command('JavaTestClass', function()
  if java.has_test then
    jdtls.test_class()
  else
    vim.notify('Java test bundle is not configured', vim.log.levels.ERROR)
  end
end, 'Run the Java test class')
command('JavaTestMethod', function()
  if java.has_test then
    jdtls.test_nearest_method()
  else
    vim.notify('Java test bundle is not configured', vim.log.levels.ERROR)
  end
end, 'Run the nearest Java test')

map('n', '<leader>jc', '<cmd>JavaCompile<cr>', { buffer = bufnr, desc = 'Java: Compile' })
map('n', '<leader>ju', '<cmd>JavaUpdateConfig<cr>', { buffer = bufnr, desc = 'Java: Update project' })
map('n', '<leader>jo', '<cmd>JavaOrganizeImports<cr>', { buffer = bufnr, desc = 'Java: Organize imports' })
map('n', '<leader>jr', '<cmd>JavaRunMain<cr>', { buffer = bufnr, desc = 'Java: Run main class' })
map('n', '<leader>js', '<cmd>JavaStopMain<cr>', { buffer = bufnr, desc = 'Java: Stop main class' })
map('n', '<leader>jl', '<cmd>JavaToggleLogs<cr>', { buffer = bufnr, desc = 'Java: Toggle output' })
map('n', '<leader>jd', '<cmd>JavaDebugMain<cr>', { buffer = bufnr, desc = 'Java: Debug main class' })
map('n', '<leader>jtc', '<cmd>JavaTestClass<cr>', { buffer = bufnr, desc = 'Java: Test class' })
map('n', '<leader>jtm', '<cmd>JavaTestMethod<cr>', { buffer = bufnr, desc = 'Java: Test method' })
map('n', '<leader>jv', jdtls.extract_variable, { buffer = bufnr, desc = 'Java: Extract variable' })
map('v', '<leader>jv', function() jdtls.extract_variable({ visual = true }) end, { buffer = bufnr, desc = 'Java: Extract variable' })
map('v', '<leader>jm', function() jdtls.extract_method({ visual = true }) end, { buffer = bufnr, desc = 'Java: Extract method' })
