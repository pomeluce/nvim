<div align='center'>

# AKIRVIM

</div>

- [使用说明](#使用说明)
- [配置说明](#配置说明)
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

### 配置说明

在配置目录下创建 `settings.json` 来自定义行为。所有配置项均为可选，未配置时使用默认值。

#### 示例

```json
{
  "mason": {
    "enable": true
  },
  "theme": {
    "enable": true
  },
  "session": {
    "projects": ["/home/user/project1", "/home/user/project2"],
    "ignore_dir": ["/tmp", "/var"]
  },
  "lsp": {
    "jdtls": {
      "runtimes": [
        {
          "name": "JavaSE-21",
          "path": "/usr/lib/jvm/java-21-openjdk"
        }
      ],
      "maven": {
        "executable": "/path/to/mvn"
      }
    }
  }
}
```

#### 配置项说明

| 配置项               | 类型       | 默认值  | 说明                                             |
| -------------------- | ---------- | ------- | ------------------------------------------------ |
| `mason.enable`       | `boolean`  | `false` | 启用 Mason 插件管理器，自动安装配置的 LSP 和 DAP |
| `theme.enable`       | `boolean`  | `false` | 启用自定义主题（mini.base16 配色方案）           |
| `session.projects`   | `string[]` | `[]`    | 项目路径列表，用于 neovim-project 项目切换       |
| `session.ignore_dir` | `string[]` | `[]`    | 自动保存 session 时忽略的目录列表                |
| `lsp.jdtls.runtimes` | `object[]` | `[]`    | jdtls Java 运行时配置，每项包含 `name` 和 `path` |
| `lsp.jdtls.maven`    | `object`   | `{}`    | jdtls Maven 配置，如 `executable` 路径           |

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
├── settings.json
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
├── registry.lua  # 注册表: 追踪插件声明/加载/延迟状态及完整 spec
├── cache.lua     # 加载耗时统计
├── ui.lua        # Pack 面板: 多 Tab 浮窗 + 异步 git 操作
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

| 命令            | 说明                               |
| --------------- | ---------------------------------- |
| `:Pack`         | 打开 Pack 面板（默认 Plugins Tab） |
| `:Pack update`  | 打开面板并切换到 Update Tab        |
| `:Pack profile` | 打开面板并切换到 Profile Tab       |
| `:Pack clean`   | 打开面板并切换到 Clean Tab         |

#### Pack 面板

统一的面板 UI，包含 4 个 Tab 页：

- **Plugins** — 查看所有已声明插件（状态、版本、加载耗时）
- **Profile** — 插件加载耗时排名（含柱状图）
- **Update** — 异步检查更新、安装缺失插件、执行更新
- **Clean** — 清理未声明的插件

面板内快捷键：

| 按键    | 说明                       |
| ------- | -------------------------- |
| `1-4`   | 切换 Tab                   |
| `S`     | Sync（安装缺失 + 更新）    |
| `U`     | 更新所有插件（Update Tab） |
| `u`     | 更新选中插件（Update Tab） |
| `X`     | 移除选中插件（二次确认）   |
| `c`     | 清理未声明插件（二次确认） |
| `C`     | 取消进行中的操作           |
| `R`     | 刷新 Profile Tab           |
| `?`     | 帮助                       |
| `q/Esc` | 关闭面板                   |

首次启动时，若检测到缺失插件会自动打开 Update Tab 并显示安装进度。
