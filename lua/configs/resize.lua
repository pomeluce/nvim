local M = {}

--[=[
Resize submode for Neovim.

Usage:
  local resize = require('configs.resize')
  resize_submode.setup({
    timeout = 500,
    step = 10,
    mappings = {
      ['s.'] = { axis = 'width', sign = 1, primary = '.' },
      ['s,'] = { axis = 'width', sign = -1, primary = ',' },
      ['sj'] = { axis = 'height', sign = 1, primary = 'j' },
      ['sk'] = { axis = 'height', sign = -1, primary = 'k' },
    },
  })

Design goals:
  1. Enter a temporary resize submode.
  2. Keep repeated resizing on the two submode keys.
  3. Exit automatically after inactivity.
  4. Keep the implementation small and predictable.
]=]

local defaults = {
  -- Inactivity timeout for leaving resize submode.
  timeout = 500,

  -- Resize step in cells.
  step = 10,

  --
  -- Entry mappings.
  -- Each value can be:
  --   * a table: { axis = 'width'|'height', sign = 1|-1, primary = '.'|','|'j'|'k' }
  --   * a function that returns the same table
  --
  -- axis:
  --   * 'width'  => left/right resize behavior
  --   * 'height' => up/down resize behavior
  --
  -- sign:
  --   * 1  => first resize grows in the primary direction
  --   * -1 => first resize shrinks in the primary direction
  --
  -- primary:
  --   * the key that continues the initial direction inside submode
  --   * the other key does the reverse
  mappings = {
    ['s.'] = { axis = 'width', sign = 1, primary = '.' },
    ['s,'] = { axis = 'width', sign = -1, primary = ',' },
    ['sj'] = { axis = 'height', sign = 1, primary = 'j' },
    ['sk'] = { axis = 'height', sign = -1, primary = 'k' },
  },

  -- Keys that are valid while submode is active.
  -- You can override this if you want to support more keys later.
  submode_keys = {
    width = { '.', ',' },
    height = { 'j', 'k' },
  },
}

local state = { active = false, gen = 0, buf = nil, axis = nil, sign = 1, primary = nil, cfg = vim.deepcopy(defaults) }

local function deep_copy(tbl) return vim.deepcopy(tbl) end

local function merge_config(opts) return vim.tbl_deep_extend('force', deep_copy(defaults), opts or {}) end

local function safe_del_map(buf, key) pcall(vim.keymap.del, 'n', key, { buffer = buf }) end

local function build_allowed_keyset(axis, cfg)
  local allowed = {}
  local keys = cfg.submode_keys and cfg.submode_keys[axis] or nil

  if type(keys) ~= 'table' then return allowed end

  for _, key in ipairs(keys) do
    allowed[key] = true
  end

  return allowed
end

local function normalize_spec(spec)
  if type(spec) == 'function' then spec = spec() end

  if type(spec) ~= 'table' then return nil end

  local axis = spec.axis
  if axis ~= 'width' and axis ~= 'height' then return nil end

  local sign = spec.sign or 1
  sign = sign < 0 and -1 or 1

  local primary = spec.primary
  if not primary then
    if axis == 'width' then
      primary = sign > 0 and '.' or ','
    else
      primary = sign > 0 and 'j' or 'k'
    end
  end

  return {
    axis = axis,
    sign = sign,
    primary = primary,
  }
end

local function resize(axis, delta)
  local win = vim.api.nvim_get_current_win()

  if axis == 'width' then
    local width = vim.api.nvim_win_get_width(win)
    vim.api.nvim_win_set_width(win, math.max(1, width + delta))
    return
  end

  local height = vim.api.nvim_win_get_height(win)
  vim.api.nvim_win_set_height(win, math.max(1, height + delta))
end

local function cleanup()
  local buf = state.buf
  local axis = state.axis

  if buf and vim.api.nvim_buf_is_valid(buf) and axis then
    for _, key in ipairs(state.cfg.submode_keys[axis] or {}) do
      safe_del_map(buf, key)
    end
  end

  state.active = false
  state.buf = nil
  state.axis = nil
  state.sign = 1
  state.primary = nil
end

local function reset_timer()
  state.gen = state.gen + 1
  local gen = state.gen
  local timeout = state.cfg.timeout or 500

  vim.defer_fn(function()
    if gen == state.gen then cleanup() end
  end, timeout)
end

local function install_submode_maps(buf, axis)
  local keys = state.cfg.submode_keys[axis] or {}
  local step = state.cfg.step or 10

  for _, key in ipairs(keys) do
    vim.keymap.set('n', key, function()
      -- Pressing the primary key keeps the initial direction.
      -- Pressing the other key reverses it.
      local delta = (key == state.primary) and (state.sign * step) or (-state.sign * step)
      resize(axis, delta)
      reset_timer()
    end, {
      buffer = buf,
      silent = true,
      nowait = true,
      noremap = true,
    })
  end
end

function M.cleanup() cleanup() end

function M.enter(spec)
  local cfg = normalize_spec(spec)
  if not cfg then return end

  state.active = true
  state.buf = vim.api.nvim_get_current_buf()
  state.axis = cfg.axis
  state.sign = cfg.sign
  state.primary = cfg.primary

  resize(cfg.axis, cfg.sign * (state.cfg.step or 10))
  install_submode_maps(state.buf, cfg.axis)
  reset_timer()
end

function M.setup(opts)
  state.cfg = merge_config(opts)

  -- Create entry mappings.
  for lhs, spec in pairs(state.cfg.mappings) do
    vim.keymap.set('n', lhs, function() M.enter(spec) end, {
      silent = true,
      noremap = true,
      desc = ('Resize submode: %s'):format(lhs),
    })
  end

  -- Auto-exit when a non-submode key is typed.
  -- This keeps the resize keys temporary instead of turning them into
  -- persistent buffer-local mappings.
  vim.on_key(function(key)
    if not state.active or not state.axis then return end

    local allowed = build_allowed_keyset(state.axis, state.cfg)
    if #key == 1 and not allowed[key] then vim.schedule(cleanup) end
  end)
end

return M
