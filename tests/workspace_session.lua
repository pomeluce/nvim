package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path

package.loaded.settings = {
  session = {
    projects = { '/projects/*' },
    ignore_dir = { '/ignored' },
  },
}

local setup_opts
package.loaded['neovim-project'] = {
  setup = function(opts) setup_opts = opts end,
}

_G.PackUtils = {
  load = function(spec, config)
    assert(spec.name == 'neovim-project')
    assert(vim.deep_equal(spec.deps, { 'neovim-session-manager', 'plenary.nvim' }))
    config()
    return true
  end,
}

local function load_session(tool_launch)
  local resolved_callback
  package.loaded['core.startup'] = {
    on_resolved = function(callback) resolved_callback = callback end,
    is_tool_launch = function() return tool_launch end,
  }

  setup_opts = nil
  dofile('./lua/plugins/workspace/session.lua')
  assert(setup_opts == nil, 'session setup must wait for startup resolution')
  resolved_callback()
  assert(setup_opts.dashboard_mode == tool_launch, ('expected dashboard_mode=%s, got %s'):format(tool_launch, setup_opts.dashboard_mode))
end

load_session(false)
load_session(true)

print('workspace session tests passed')
