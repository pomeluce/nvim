local M = {}
local definition_origins = {}
local keys = {
  compile = '<leader>jc',
  update_config = '<leader>ju',
  organize_imports = '<leader>jo',
  run = '<leader>jr',
  stop = '<leader>js',
  toggle_logs = '<leader>jl',
  next_log = 'gt',
  previous_log = 'gT',
  next_log_tab = '<Tab>',
  previous_log_tab = '<S-Tab>',
  debug = '<leader>jd',
  test_class = '<leader>jtc',
  test_method = '<leader>jtm',
  extract_variable = '<leader>jv',
  extract_method = '<leader>jm',
}

local function set_definition_origin(tabpage, bufnr) definition_origins[tabpage] = bufnr end

local function take_definition_origin(tabpage)
  local bufnr = definition_origins[tabpage]
  definition_origins[tabpage] = nil
  return bufnr
end

function M.attach_classfile(bufnr)
  if not vim.startswith(vim.api.nvim_buf_get_name(bufnr), 'jdt://') then return false end

  local origin = take_definition_origin(vim.api.nvim_get_current_tabpage())
  vim.b[bufnr].transient = true
  if type(origin) == 'number' and vim.api.nvim_buf_is_valid(origin) then vim.b[bufnr].transient_origin = origin end
  vim.bo[bufnr].buflisted = false
  vim.bo[bufnr].bufhidden = 'wipe'
  vim.bo[bufnr].swapfile = false
  return true
end

local function command(bufnr, name, callback, description)
  pcall(vim.api.nvim_buf_del_user_command, bufnr, name)
  vim.api.nvim_buf_create_user_command(bufnr, name, callback, { desc = description })
end

local function attach_runner_commands(bufnr, java)
  command(bufnr, 'JavaStopMain', function() java.runner:stop() end, 'Stop the running Java main class')
  command(bufnr, 'JavaToggleLogs', function() java.runner:toggle() end, 'Toggle Java run output')
  command(bufnr, 'JavaNextLog', function() java.runner:switch_log(1) end, 'Show the next Java run output')
  command(bufnr, 'JavaPreviousLog', function() java.runner:switch_log(-1) end, 'Show the previous Java run output')
end

local function attach_log_buffer(bufnr, java)
  attach_runner_commands(bufnr, java)
  vim.keymap.set('n', keys.stop, '<cmd>JavaStopMain<cr>', {
    buffer = bufnr,
    desc = 'Java: Stop main class',
    silent = true,
  })
  vim.keymap.set('n', keys.toggle_logs, '<cmd>JavaToggleLogs<cr>', {
    buffer = bufnr,
    desc = 'Java: Toggle output',
    silent = true,
  })
  vim.keymap.set('n', keys.next_log, '<cmd>JavaNextLog<cr>', {
    buffer = bufnr,
    desc = 'Java: Next output',
    silent = true,
  })
  vim.keymap.set('n', keys.previous_log, '<cmd>JavaPreviousLog<cr>', {
    buffer = bufnr,
    desc = 'Java: Previous output',
    silent = true,
  })
  vim.keymap.set('n', keys.next_log_tab, '<cmd>JavaNextLog<cr>', {
    buffer = bufnr,
    desc = 'Java: Next output',
    silent = true,
  })
  vim.keymap.set('n', keys.previous_log_tab, '<cmd>JavaPreviousLog<cr>', {
    buffer = bufnr,
    desc = 'Java: Previous output',
    silent = true,
  })
  vim.keymap.set('n', 'q', '<cmd>JavaToggleLogs<cr>', {
    buffer = bufnr,
    desc = 'Java: Close output',
    silent = true,
  })
end

local function goto_definition(bufnr)
  local client = vim.lsp.get_clients({ name = 'jdtls', bufnr = bufnr })[1]
  if not client then
    vim.notify('No jdtls client attached', vim.log.levels.WARN)
    return
  end

  local origin = vim.api.nvim_get_current_buf()
  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
  client:request('textDocument/definition', params, function(_, result)
    if not result or vim.tbl_isempty(result) then
      vim.notify('No definition found', vim.log.levels.INFO)
      return
    end

    local locations = vim.islist(result) and result or { result }
    if vim.iter(locations):any(function(location) return vim.startswith(location.uri or location.targetUri or '', 'jdt://') end) then
      set_definition_origin(vim.api.nvim_get_current_tabpage(), origin)
    end
    if #locations == 1 then
      vim.lsp.util.show_document(locations[1], client.offset_encoding, { reuse_win = true, focus = true })
    else
      Snacks.picker.lsp_definitions()
    end
  end, bufnr)
end

function M.attach(bufnr, java)
  local jdtls = require('jdtls')
  local map = vim.keymap.set

  java.runner:set_log_buffer_attach(function(log_bufnr) attach_log_buffer(log_bufnr, java) end)

  map('n', 'gd', function() goto_definition(bufnr) end, { buffer = bufnr, desc = 'Java: Goto definition' })

  command(bufnr, 'JavaCompile', function()
    jdtls.compile('full', function(items)
      if not items or #items == 0 then return end
      vim.schedule(function()
        vim.cmd('botright copen')
        local quickfix_buf = vim.api.nvim_get_current_buf()
        vim.keymap.set('n', 'q', '<cmd>cclose<cr>', {
          buffer = quickfix_buf,
          desc = 'Java: Close compile results',
          silent = true,
        })
        vim.bo[quickfix_buf].buflisted = false
      end)
    end)
  end, 'Build Java workspace')
  command(bufnr, 'JavaUpdateConfig', jdtls.update_project_config, 'Update Maven/Gradle project config')
  command(bufnr, 'JavaOrganizeImports', jdtls.organize_imports, 'Organize Java imports')
  command(bufnr, 'JavaRunMain', function() java.runner:start() end, 'Run a Java main class')
  attach_runner_commands(bufnr, java)
  command(bufnr, 'JavaDebugMain', function() java.runner:debug() end, 'Debug a Java main class')
  command(bufnr, 'JavaTestClass', function()
    if java.has_test then
      jdtls.test_class()
    else
      vim.notify('Java test bundle is not configured', vim.log.levels.ERROR)
    end
  end, 'Run the Java test class')
  command(bufnr, 'JavaTestMethod', function()
    if java.has_test then
      jdtls.test_nearest_method()
    else
      vim.notify('Java test bundle is not configured', vim.log.levels.ERROR)
    end
  end, 'Run the nearest Java test')

  local mappings = {
    { mode = 'n', lhs = keys.compile, rhs = '<cmd>JavaCompile<cr>', desc = 'Java: Compile' },
    { mode = 'n', lhs = keys.update_config, rhs = '<cmd>JavaUpdateConfig<cr>', desc = 'Java: Update project' },
    { mode = 'n', lhs = keys.organize_imports, rhs = '<cmd>JavaOrganizeImports<cr>', desc = 'Java: Organize imports' },
    { mode = 'n', lhs = keys.run, rhs = '<cmd>JavaRunMain<cr>', desc = 'Java: Run main class' },
    { mode = 'n', lhs = keys.stop, rhs = '<cmd>JavaStopMain<cr>', desc = 'Java: Stop main class' },
    { mode = 'n', lhs = keys.toggle_logs, rhs = '<cmd>JavaToggleLogs<cr>', desc = 'Java: Toggle output' },
    { mode = 'n', lhs = keys.debug, rhs = '<cmd>JavaDebugMain<cr>', desc = 'Java: Debug main class' },
    { mode = 'n', lhs = keys.test_class, rhs = '<cmd>JavaTestClass<cr>', desc = 'Java: Test class' },
    { mode = 'n', lhs = keys.test_method, rhs = '<cmd>JavaTestMethod<cr>', desc = 'Java: Test method' },
    { mode = 'n', lhs = keys.extract_variable, rhs = jdtls.extract_variable, desc = 'Java: Extract variable' },
    { mode = 'v', lhs = keys.extract_variable, rhs = function() jdtls.extract_variable({ visual = true }) end, desc = 'Java: Extract variable' },
    { mode = 'v', lhs = keys.extract_method, rhs = function() jdtls.extract_method({ visual = true }) end, desc = 'Java: Extract method' },
  }
  for _, mapping in ipairs(mappings) do
    map(mapping.mode, mapping.lhs, mapping.rhs, { buffer = bufnr, desc = mapping.desc })
  end
end

return M
