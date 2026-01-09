---@type vim.lsp.Config
return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if path ~= vim.fn.stdpath('config') and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = { version = 'LuaJIT', path = { 'lua/?.lua', 'lua/?/init.lua' } },
      workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
    })
  end,
  settings = {
    Lua = {
      -- 告诉语言服务器使用的 lua 版本是 LuaJIT
      runtime = { version = 'LuaJIT' },
      -- 让语言服务器识别 vim 全局变量
      diagnostics = {
        -- globals = { 'vim' },
      },
      -- neovim 运行时文件
      workspace = { library = vim.api.nvim_get_runtime_file('', true), checkThirdParty = false },
      -- 不发送测试数据
      telemetry = { enable = false },
    },
  },
}
