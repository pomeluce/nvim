return {
  settings = {
    Lua = {
      -- 告诉语言服务器使用的 lua 版本是 LuaJIT
      runtime = {
        version = 'LuaJIT',
      },
      -- 让语言服务器识别 vim 全局变量
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        -- neovim 运行时文件
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.stdpath("config") .. "/lua"] = true,
        },
        checkThirdParty = false,
      },
      -- 不发送测试数据
      telemetry = {
        enable = false,
      },
    },
  },
}
