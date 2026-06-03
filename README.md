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
│   ├── plugins
│   └── utils.lua
├── nvim-pack-lock.json
├── README.md
├── settings.json
└── snippets
```

### PackUtils 插件管理

基于 Neovim 0.12 原生 `vim.pack` API 的轻量插件管理，全部逻辑在 `lua/core/setup.lua` 中。

#### 架构

```
lua/core/setup.lua
├── specs 列表          — 声明所有插件及其版本约束
├── PackUtils.sync()    — 自动清理不在 specs 中的孤儿插件
├── PackUtils.load()    — 插件加载引擎（防重复、依赖管理、构建触发）
├── PackUtils.run_build() — 异步构建（build_cmd + .build_done 防重复）
├── :PkUpdate           — 更新插件（支持 Tab 补全、! 强制模式）
└── :PkStatus           — 查看插件当前版本/状态（离线）
```

#### Spec 格式

```lua
---@type PackUtils.Spec[]
local specs = {
  -- 基础: 仅声明 Git 仓库
  { src = 'https://github.com/nvim-lua/plenary.nvim' },

  -- 版本约束: 支持 semver range 或 git branch 名
  { src = 'https://github.com/saghen/blink.cmp', version = 'v1.*' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects', version = 'main' },

  -- 条件启用: boolean 或 function → boolean
  { src = 'https://github.com/mason-org/mason.nvim', enabled = require('settings').mason.enable },
  { src = 'https://github.com/...', enabled = false },
  { src = 'https://github.com/...', enabled = function() return vim.fn.executable('some-tool') == 1 end },
}
```

#### PackUtils.load()

在 `plugins/*.lua` 中调用，加载并配置单个插件：

```lua
PackUtils.load({
  name = 'blink.cmp',           -- 插件名（必填）
  deps = { 'LuaSnip', '...' },  -- 依赖（可选，先于主插件挂载）
  enabled = true,               -- boolean | function → boolean (默认 true)
  loaded = true,                -- boolean | function → boolean (默认 true)
  build_cmd = ':TSUpdate',      -- 构建命令（可选，支持 :vim-cmd 或 shell）
}, function()
  require('blink.cmp').setup({ ... })
end)
```

#### 控制层级

| 参数              | 位置             | false 时的效果                |
| ----------------- | ---------------- | ----------------------------- |
| `enabled` (specs) | `local specs`    | 不下载、不 packadd、不 config |
| `enabled` (load)  | `PackUtils.load` | 不 packadd、不 config         |
| `loaded`          | `PackUtils.load` | 仅 packadd，不执行 config_fn  |

#### 构建系统

通过 `build_cmd` 声明构建任务，`PackUtils` 自动管理：

- `.build_done` stamp 文件防止重复构建
- `PackChanged` autocmd 在更新/安装后触发重新构建
- `:vim-cmd` 在 Neovim 主线程执行，shell 命令异步后台执行

#### 命令

| 命令                    | 说明                                          |
| ----------------------- | --------------------------------------------- |
| `:PkUpdate [plugin...]` | 更新插件（无参数时全部更新），加 `!` 跳过确认 |
| `:PkStatus [plugin...]` | 查看插件当前版本/状态（离线）                 |
