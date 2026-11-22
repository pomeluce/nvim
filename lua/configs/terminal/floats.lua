local M = {}

local Terminal = require('toggleterm.terminal').Terminal

-- 命名单实例浮动终端。
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

return M
