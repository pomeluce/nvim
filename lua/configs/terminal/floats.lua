local M = {}

local Terminal = require('toggleterm.terminal').Terminal
local api = vim.api
local float_opts = require('configs.terminal.options').float

-- 命名单实例浮动终端(RUN、Codex 等)。
local terminals = {}

local function valid_directory(path)
  if type(path) ~= 'string' or path == '' then return end
  path = vim.fs.normalize(path)
  local stat = vim.uv.fs_stat(path)
  return stat and stat.type == 'directory' and path or nil
end

local function codex_working_directory()
  local buffer_name = api.nvim_buf_get_name(0)
  local buffer_dir = valid_directory(buffer_name ~= '' and vim.fs.dirname(buffer_name) or nil)
  local ok, cwd = pcall(vim.fn.getcwd)
  local current_dir = ok and valid_directory(cwd) or nil
  local root_start = buffer_dir or current_dir
  local git_root = root_start and valid_directory(vim.fs.root(root_start, '.git')) or nil

  return git_root or current_dir or buffer_dir or valid_directory(vim.uv.cwd()) or valid_directory(vim.fn.expand('~'))
end

function M.cleanup_artifacts(artifacts, attempt)
  if not artifacts or #artifacts == 0 then return end
  local pending = {}
  for _, artifact in ipairs(artifacts) do
    local deleted = artifact.recursive and vim.fn.delete(artifact.path, 'rf') or vim.fn.delete(artifact.path)
    if deleted ~= 0 and vim.uv.fs_stat(artifact.path) then pending[#pending + 1] = artifact end
  end
  attempt = (attempt or 0) + 1
  if #pending > 0 and attempt < 20 then vim.defer_fn(function() M.cleanup_artifacts(pending, attempt) end, 50) end
end

local function cleanup_terminal(t)
  local artifacts = t and t._cleanup_artifacts
  if not artifacts then return end
  t._cleanup_artifacts = nil
  vim.schedule(function() M.cleanup_artifacts(artifacts) end)
end

function M.floaterm(name, cmd, close, opts, cleanup)
  -- 同名终端每次重新执行命令，避免复用已退出的 buffer 或泄漏旧进程。
  local prev = terminals[name]
  if prev then
    if prev:is_open() then prev:close() end
    if prev.shutdown then pcall(prev.shutdown, prev) end
    cleanup_terminal(prev)
    terminals[name] = nil
  end

  local terminal = Terminal:new({
    cmd = cmd ~= '' and cmd or nil,
    display_name = name,
    dir = 'git_dir',
    close_on_exit = close or false,
    float_opts = opts,
    hidden = true,
    on_open = function() vim.cmd('startinsert!') end,
    on_exit = function(t) cleanup_terminal(t) end,
  })
  terminal._cleanup_artifacts = cleanup
  terminals[name] = terminal

  if name == 'RUN' then terminal.dir = vim.fn.fnamemodify(vim.fn.expand('%'), ':p:h') end
  terminal:toggle()
end

local function open_codex(command, dir)
  dir = valid_directory(dir)
  if not dir then return false, '工作目录已失效' end

  local codex
  local function send_ctrl_t()
    if codex.job_id then vim.fn.chansend(codex.job_id, string.char(20)) end
  end

  codex = Terminal:new({
    cmd = command,
    display_name = 'Codex',
    dir = dir,
    close_on_exit = true,
    float_opts = float_opts,
    hidden = true,
    on_open = function(t)
      vim.keymap.set('t', '<C-t>', send_ctrl_t, { buffer = t.bufnr, desc = 'Send Ctrl-T to Codex', silent = true, nowait = true })
      vim.keymap.set('n', '<C-t>', function()
        send_ctrl_t()
        vim.cmd('startinsert!')
      end, { buffer = t.bufnr, desc = 'Send Ctrl-T to Codex', silent = true, nowait = true })
      vim.cmd('startinsert!')
    end,
    on_exit = function(t)
      if terminals.CODEX == t then terminals.CODEX = nil end
    end,
  })
  terminals.CODEX = codex
  local ok, err = pcall(codex.toggle, codex)
  if ok then return true end

  if terminals.CODEX == codex then terminals.CODEX = nil end
  if codex.shutdown then pcall(codex.shutdown, codex) end
  return false, err
end

-- Codex 隐藏时保留进程，退出后自动销毁窗口和 buffer。
function M.toggle_codex(command)
  local current = terminals.CODEX
  if current and current.bufnr and api.nvim_buf_is_valid(current.bufnr) then
    current:toggle()
    return
  end

  if not command or command == '' then
    if vim.fn.executable('codex') ~= 1 then
      vim.notify('未找到 codex 可执行文件', vim.log.levels.ERROR, { title = 'Terminal' })
      return
    end
    command = 'codex resume'
  end

  local dir = codex_working_directory()
  if not dir then
    vim.notify('无法找到有效的 Codex 工作目录', vim.log.levels.ERROR, { title = 'Terminal' })
    return
  end

  local ok, err = open_codex(command, dir)
  if not ok then vim.notify('无法打开 Codex 终端: ' .. tostring(err), vim.log.levels.ERROR, { title = 'Terminal' }) end
end

return M
