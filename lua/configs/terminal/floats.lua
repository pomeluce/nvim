local M = {}

local Terminal = require('toggleterm.terminal').Terminal
local api = vim.api
local float_opts = require('configs.terminal.options').float

-- 命名单实例浮动终端(RUN、Codex 等)。
local terminals = {}

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

  local codex
  codex = Terminal:new({
    cmd = command,
    display_name = 'Codex',
    dir = 'git_dir',
    close_on_exit = true,
    float_opts = float_opts,
    hidden = true,
    on_open = function() vim.cmd('startinsert!') end,
    on_exit = function(t)
      if terminals.CODEX == t then terminals.CODEX = nil end
    end,
  })
  terminals.CODEX = codex
  codex:toggle()
end

return M
