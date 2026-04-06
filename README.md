<div align='center'>

# AKIRVIM

</div>

- [使用说明](#使用说明)
- [目录结构](#目录结构)
- [Packman 插件管理](#packman-插件管理)

### 使用说明

1. backup 原有 nvim 配置, 并删除 nvim 数据目录

```
cp ~/.config/nvim /you/backup/path/nvim-bak

rm -rf ~/.local/share/nvim/
```

2. 所需环境(以 nixos 为例)

```nix
{
  environment.systemPackages = with pkgs; [
    bat
    fd
    fzf
    ripgrep
    silver-searcher
    tree-sitter
    unzip
    wl-clipboard
    luajitPackages.luarocks
    luajitPackages.jsregexp
    python314Packages.pynvim
    translate-shell
    imagemagick

    # lsp
    basedpyright
    bash-language-server
    clang-tools
    cmake-language-server
    copilot-language-server
    emmet-language-server
    kotlin-language-server
    lua-language-server
    marksman
    nil
    rust-analyzer
    tailwindcss-language-server
    taplo
    typescript-language-server
    vscode-langservers-extracted
    vue-language-server

    # dap
    gdb
    vscode-extensions.ms-vscode.cpptools
    vscode-extensions.vadimcn.vscode-lldb.adapter
    vscode-extensions.vscjava.vscode-java-debug
    vscode-js-debug
    vscode-extensions.firefox-devtools.vscode-firefox-debug

    # fmt
    beautysh
    cbfmt
    nixfmt
    prettier
    prettierd
    ruff
    rustfmt
    shfmt
    sqlfluff
    stylua
  ];
}
```

3. 拉取 akirvim 配置

```shell
cd ~/.config/ && git clone https://github.com/pomeluce/nvim.git
```

4. 执行 nvim 命令, 等待安装完成

```
nvim
```

### 目录结构

```
.
├── after
│   ├── ftplugin
│   ├── lsp
│   └── plugin
├── init.lua
├── LICENSE
├── lua
│   ├── configs
│   ├── core
│   ├── packman
│   ├── plugins
│   └── utils.lua
├── nvim-pack-lock.json
├── README.md
└── snippets
```

### Packman 插件管理

基于 Neovim 0.12 原生 `vim.pack` API 的声明式插件管理框架，提供类似 lazy.nvim 的使用体验。

#### 模块结构

```
lua/packman/
├── init.lua      # 入口: setup() 收集 spec 并加载插件
├── spec.lua      # Spec 解析: 短格式转 URL、推断 name、校验字段
├── loader.lua    # 加载引擎: vim.pack.add() 注册、延迟加载调度
├── registry.lua  # 注册表: 追踪插件声明/加载/延迟状态
├── cache.lua     # 加载耗时统计
├── ui.lua        # 浮窗 UI + Pack 命令
└── types.lua     # 类型定义(---@type packman.SpecItem[])
```

#### Spec 格式

```lua
---@type packman.SpecItem[]
return {
  {
    'owner/repo',                        -- 短格式, 自动转为 GitHub URL
    event = 'VimEnter',                  -- 延迟加载: 事件 / keys / cmd / ft
    dependencies = { 'dep/one' },        -- 依赖(自动先加载)
    opts = { ... },                      -- 传给 require().setup() 的配置
    config = function() ... end,         -- 自定义配置(替代 opts)
    main = 'custom-module',              -- 覆盖推断的 Lua 模块名
    version = 'main',                    -- 版本约束或 git branch
    enabled = true,                      -- 是否启用
  },
}
```

#### 延迟加载

| 条件     | 示例                 | 触发方式                 |
| -------- | -------------------- | ------------------------ |
| 事件     | `event = 'UIEnter'`  | `autocmd`                |
| 按键     | `keys = '<leader>s'` | 首次按键时加载并重新触发 |
| 命令     | `cmd = 'Neogen'`     | 首次执行命令时加载并执行 |
| 文件类型 | `ft = 'python'`      | `FileType` autocmd       |

#### 命令

| 命令                 | 说明                             |
| -------------------- | -------------------------------- |
| `:PackInstalled`     | 查看已安装插件(含状态和版本)     |
| `:PackStatus`        | 查看插件加载状态和耗时           |
| `:PackProfile`       | 查看插件加载耗时排名             |
| `:PackSync`          | 安装缺失 + 清理未声明 + 更新已有 |
| `:PackUpdate`        | 更新所有插件                     |
| `:PackRemove <name>` | 删除指定插件                     |
| `:PackClean`         | 清理未声明的插件                 |
