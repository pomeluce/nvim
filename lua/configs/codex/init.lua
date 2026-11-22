local context = require('configs.codex.context')
local terminal = require('configs.codex.terminal')

local M = {}
local defaults = {
  codex_cmd = 'codex',
  codex_args = {},
  split_width_percentage = 0.40,
}
local config = vim.deepcopy(defaults)
local sessions = {}
local next_instance_sequence = 0

function M.setup(opts)
  local updated = vim.tbl_extend('force', defaults, opts or {})
  vim.validate('codex_cmd', updated.codex_cmd, 'string')
  vim.validate('codex_args', updated.codex_args, 'table')
  vim.validate(
    'split_width_percentage',
    updated.split_width_percentage,
    function(value) return type(value) == 'number' and value > 0 and value < 1 end,
    'a fraction between 0 and 1'
  )
  updated.codex_cmd = vim.fn.expand(updated.codex_cmd)
  config = updated
end

local function session_for(root)
  root = root or context.root()
  if not sessions[root] then
    next_instance_sequence = next_instance_sequence + 1
    sessions[root] = {
      root = root,
      pending = {},
      return_to = {},
      instance_sequence = next_instance_sequence,
    }
  end
  return sessions[root]
end

local function notify(message, level) vim.notify(message, level or vim.log.levels.INFO, { title = 'Codex' }) end

local function show(session, focus, args)
  for _, other in pairs(sessions) do
    if other ~= session then terminal.hide(other) end
  end
  local ok, err = pcall(terminal.show, session, config, focus, args)
  if not ok then
    terminal.hide(session)
    notify('Cannot open Codex sidebar: ' .. err, vim.log.levels.ERROR)
  end
  return ok
end

function M.toggle()
  local session = session_for()
  if terminal.visible(session) then
    terminal.hide(session)
  else
    show(session, true)
  end
end

function M.focus() show(session_for(), true) end

function M.close()
  for _, session in pairs(sessions) do
    if terminal.visible(session) then
      session.pending = {}
      terminal.hide(session)
      return
    end
  end
end

local function slash(session, command)
  if terminal.empty_composer(session) and terminal.send(session, command .. '\r') then return end
  notify('Use ' .. command .. ' in the Codex composer')
end

function M.new()
  local session = session_for()
  local active = session.job ~= nil
  if show(session, true) and active then slash(session, '/new') end
end

function M.resume()
  local session = session_for()
  local active = session.job ~= nil
  if show(session, true, { 'resume' }) and active then slash(session, '/resume') end
end

function M.continue() show(session_for(), true, { 'resume', '--last' }) end

local function add_to_draft(session, text)
  table.insert(session.pending, text)
  show(session, false)
end

local function add_path(session, path) add_to_draft(session, context.path_reference(session.root, path)) end

function M.add(opts)
  local session = session_for()
  local name = opts.args
  local path = name ~= '' and name ~= '%' and vim.fs.abspath(name) or context.buffer_path()
  if path then
    add_path(session, path)
  else
    notify('Open a file or supply a path to :CodexAdd', vim.log.levels.WARN)
  end
end

function M.selection(opts)
  local text, path, start_line, end_line = context.selection(opts)
  local session = session_for()
  if text and path then
    add_to_draft(session, context.path_reference(session.root, path, start_line, end_line))
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)
  else
    notify('Select text or supply a line range to :CodexSend', vim.log.levels.WARN)
  end
end

function M.tree()
  local path = context.tree_path()
  if path then
    add_path(session_for(context.root(path)), path)
  else
    notify('No local file explorer entry under the cursor', vim.log.levels.WARN)
  end
end

function M.interrupt()
  local session = session_for()
  if session.status == 'working' and terminal.send(session, '\27') then return end
  notify('Focus Codex and use its interrupt key')
end

function M.diff()
  local session = session_for()
  if show(session, true) then slash(session, '/diff') end
end

return M
