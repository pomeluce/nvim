local M = {}
local definition_origins = {}

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

local function goto_definition(bufnr)
  local origin = vim.api.nvim_get_current_buf()
  local params = vim.lsp.util.make_position_params(0, 'utf-8')
  vim.lsp.buf_request(bufnr, 'textDocument/definition', params, function(_, result, ctx)
    if not result or vim.tbl_isempty(result) then
      vim.notify('No definition found', vim.log.levels.INFO)
      return
    end

    local locations = vim.islist(result) and result or { result }
    if vim.iter(locations):any(function(location) return vim.startswith(location.uri or location.targetUri or '', 'jdt://') end) then
      set_definition_origin(vim.api.nvim_get_current_tabpage(), origin)
    end
    if #locations == 1 then
      local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
      vim.lsp.util.show_document(locations[1], client.offset_encoding, { reuse_win = true, focus = true })
    else
      Snacks.picker.lsp_definitions()
    end
  end)
end

function M.attach(bufnr, java)
  local jdtls = require('jdtls')
  local map = vim.keymap.set

  map('n', 'gd', function() goto_definition(bufnr) end, { buffer = bufnr, desc = 'Java: Goto definition' })

  command(bufnr, 'JavaCompile', function()
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
  command(bufnr, 'JavaUpdateConfig', jdtls.update_project_config, 'Update Maven/Gradle project config')
  command(bufnr, 'JavaOrganizeImports', jdtls.organize_imports, 'Organize Java imports')
  command(bufnr, 'JavaRunMain', function() java.runner:start() end, 'Run a Java main class')
  command(bufnr, 'JavaStopMain', function() java.runner:stop() end, 'Stop the running Java main class')
  command(bufnr, 'JavaToggleLogs', function() java.runner:toggle() end, 'Toggle Java run output')
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
end

return M
