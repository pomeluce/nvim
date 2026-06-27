<div align='center'>

# AKIRVIM

基于 Neovim 0.12+ 原生 `vim.pack` API 的轻量 Neovim 配置。

</div>

## 环境要求

| 依赖      | 最低版本  | 说明                                                                      |
| --------- | --------- | ------------------------------------------------------------------------- |
| Neovim    | **0.12+** | 依赖 `vim.fs.root()`、`vim.system()`、`vim.pack` 等 0.11/0.12 API         |
| Git       | 2.0+      | 插件克隆                                                                  |
| Nerd Font | —         | 图标显示（推荐 [Maple Mono](https://github.com/subframe7536/Maple-font)） |

## 特性

- **零插件管理器** — 基于 Neovim 内置 `vim.pack` 的 PackUtils，无需 lazy.nvim / packer
- **跨平台** — 同时支持 NixOS（`extraPackages` 注入）和非 NixOS（Mason 自动安装）
- **Java 全栈** — jdtls + DAP + JavaRunner，语法高亮 / 补全 / 跳转 / 运行 / 调试 / 测试
- **LSP** — nvim-lspconfig + blink.cmp，覆盖 15+ 语言
- **DAP** — nvim-dap + nvim-dap-ui，支持 C/C++ / Java / Python / Node.js
- **搜索** — Snacks picker（文件 / Grep / 符号 / 诊断 / TODO）
- **编辑增强** — Flash 跳转、nvim-surround 环绕、ts-comments 注释、switch 转换

## 快速开始

```shell
# 备份原有配置
cp -r ~/.config/nvim ~/nvim-bak
rm -rf ~/.local/share/nvim/ ~/.local/state/nvim/

# 克隆配置
cd ~/.config && git clone https://github.com/pomeluce/nvim.git

# 首次启动，等待插件自动安装
nvim
```

首次启动后会自动安装插件并生成 `nvim-pack-lock.json`。插件更新使用 `:PkUpdate`。

## 安装（分平台）

### NixOS / Nix (home-manager)

在 `configuration.nix` 或 home-manager 中声明所有依赖，nvim 零下载：

```nix
{
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      # === 基础工具 ===
      bat fd fzf ripgrep tree-sitter unzip wl-clipboard
      luajitPackages.jsregexp
      python314Packages.pynvim

      # === 插件外部依赖 ===
      translate-shell      # translate.nvim
      imagemagick          # img-clip.nvim
      kulala-core          # kulala.nvim

      # === LSP ===
      bash-language-server
      clang-tools             # C/C++
      cmake-language-server
      copilot-language-server
      docker-language-server
      emmet-language-server
      jdt-language-server     # Java
      kotlin-language-server
      lemminx                 # XML
      lua-language-server
      marksman                # Markdown
      nixd                    # Nix
      rust-analyzer
      tailwindcss-language-server
      taplo                   # TOML
      ty                      # Python
      typescript-language-server
      vscode-langservers-extracted  # HTML/CSS/JSON
      vue-language-server

      # === DAP ===
      gdb
      vscode-extensions.ms-vscode.cpptools
      vscode-extensions.vadimcn.vscode-lldb.adapter
      vscode-extensions.vscjava.vscode-java-debug
      vscode-extensions.vscjava.vscode-java-test
      vscode-js-debug
      vscode-extensions.firefox-devtools.vscode-firefox-debug

      # === Formatter ===
      beautysh              # shell
      cbfmt                 # Markdown code block
      dockerfmt
      google-java-format    # Java
      kulala-fmt            # HTTP
      libxml2               # XML (xmllint)
      nixfmt
      nufmt                 # Nushell
      prettierd             # JS/TS/HTML/CSS/JSON/YAML
      ruff                  # Python
      rustfmt
      shfmt                 # shell
      sqlfluff              # SQL
      stylua                # Lua

      # === Java ===
      lombok
    ];
  };
}
```

### 非 NixOS（Linux / macOS / Windows WSL）

启用 Mason 自动安装 LSP/DAP/Formatter。在 `~/.config/nvim/settings.toml` 中：

```toml
[mason]
enable = true
```

首次启动 nvim 后 Mason 会自动安装 `mason-lspconfig.nvim` 和 `mason-nvim-dap.nvim` 中声明的所有服务器。可用 `:Mason` 查看和管理安装状态。

**前置依赖**（需通过系统包管理器手动安装）：

| 工具          | 用途           | Arch                      | Ubuntu/Debian | macOS (brew)                    |
| ------------- | -------------- | ------------------------- | ------------- | ------------------------------- |
| `git`         | 插件克隆       | `git`                     | `git`         | —                               |
| `fd`          | 文件搜索       | `fd`                      | `fd-find`     | `fd`                            |
| `fzf`         | 模糊搜索       | `fzf`                     | `fzf`         | `fzf`                           |
| `ripgrep`     | 文本搜索       | `ripgrep`                 | `ripgrep`     | `ripgrep`                       |
| `tree-sitter` | 语法解析       | `tree-sitter`             | —             | `tree-sitter`                   |
| `unzip`       | 解压           | `unzip`                   | `unzip`       | —                               |
| `lazygit`     | Git UI（可选） | `lazygit`                 | —             | `lazygit`                       |
| Nerd Font     | 图标           | `ttf-jetbrains-mono-nerd` | —             | `font-jetbrains-mono-nerd-font` |

**Python 支持**（可选，用于 pynvim 和 Python LSP）：

```shell
pip install pynvim basedpyright
```

### Mason 自动安装列表

以下 LSP 服务器在 `mason.enable = true` 时自动安装：

```
basedpyright, bashls, clangd, cmake, cssls, emmet_language_server,
html, jsonls, kotlin_language_server, lua_ls, marksman, nil_ls,
rust_analyzer, tailwindcss, taplo, ts_ls, vue_ls
```

DAP 和 Formatter 也通过 Mason 的 `automatic_installation = true` 自动管理。

## 环境变量

以下环境变量被配置引用。**NixOS 用户**在 `home.sessionVariables` 中设置；**非 NixOS 用户**在 shell 配置（`.zshrc` / `.bashrc`）中设置。

| 变量                | 用途                             | 示例值                          | 必须     |
| ------------------- | -------------------------------- | ------------------------------- | -------- |
| `JAVA_LOMBOK`       | Lombok jar 路径（Java 项目需要） | `/usr/share/java/lombok.jar`    | 否       |
| `VSC_JAVA_DEBUG`    | vscode-java-debug 扩展路径       | `/path/to/vscode-java-debug`    | 否\*     |
| `VSC_JAVA_TEST`     | vscode-java-test 扩展路径        | `/path/to/vscode-java-test`     | 否\*     |
| `VSC_FIREFOX_DEBUG` | vscode-firefox-debug 扩展路径    | `/path/to/vscode-firefox-debug` | 否       |
| `PYTHON`            | Python 解释器（pynvim）          | `/usr/bin/python3`              | 否       |
| `USER` / `USERNAME` | 用户名（模板 header）            | —                               | 自动获取 |

> \* Java DAP 调试和测试功能需要这两个变量。未设置时会有一次性警告提示，不影响编译和运行。

### NixOS 设置示例

```nix
home.sessionVariables = {
  JAVA_LOMBOK    = "${pkgs.lombok}/share/java/lombok.jar";
  VSC_JAVA_DEBUG = "${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug";
  VSC_JAVA_TEST  = "${pkgs.vscode-extensions.vscjava.vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test";
};
```

### 非 NixOS 设置示例

```shell
# ~/.zshrc 或 ~/.bashrc
export JAVA_LOMBOK="/usr/share/java/lombok.jar"
export VSC_JAVA_DEBUG="$HOME/.local/share/nvim/mason/packages/java-debug-adapter"
export VSC_JAVA_TEST="$HOME/.local/share/nvim/mason/packages/java-test"
export PYTHON="$(which python3)"
```

## 配置 (settings.toml)

在 `~/.config/nvim/settings.toml` 中创建配置文件。所有配置项均为可选。

### 完整示例

```toml
# === Mason 插件管理器 ===
# NixOS: false（通过 extraPackages 注入）
# 非 NixOS: true（自动安装 LSP/DAP/Formatter）
[mason]
enable = false

# === Session 管理 ===
[session]
# neovim-project 的项目路径列表
projects = ["~/devspace/code/project1", "~/devspace/code/project2"]
# 自动保存 session 时忽略的目录
ignore_dir = ["/tmp", "/var"]

# === Java LSP (jdtls) ===
[lsp.jdtls.maven]
# Maven settings.xml 路径（用于内网仓库认证等）
userSettings = "~/.m2/settings.xml"
globalSettings = "~/.m2/global-settings.xml"

# Java 运行时配置（name 必须是标准 JavaSE 名称）
[[lsp.jdtls.runtimes]]
name = "JavaSE-1.8"
path = "/usr/lib/jvm/java-8-openjdk"

[[lsp.jdtls.runtimes]]
name = "JavaSE-21"
path = "/usr/lib/jvm/java-21-openjdk"
default = true   # 标记为默认运行时

# 命令运行配置（通过 file_key 映射执行命令）
[file.run_cmd]
"python" = "python3 %"
"lua"    = "lua %"
```

### 配置项参考

| 配置项                           | 类型       | 默认值  | 说明                                              |
| -------------------------------- | ---------- | ------- | ------------------------------------------------- |
| `mason.enable`                   | `boolean`  | `false` | 启用 Mason 自动管理 LSP/DAP/Formatter             |
| `session.projects`               | `string[]` | `[]`    | neovim-project 项目列表                           |
| `session.ignore_dir`             | `string[]` | `[]`    | session 自动保存时忽略的目录                      |
| `lsp.jdtls.runtimes[].name`      | `string`   | —       | JavaSE 运行时名称（如 `JavaSE-1.8`、`JavaSE-21`） |
| `lsp.jdtls.runtimes[].path`      | `string`   | —       | JDK 安装路径                                      |
| `lsp.jdtls.runtimes[].default`   | `boolean`  | `false` | 是否为默认运行时                                  |
| `lsp.jdtls.maven.userSettings`   | `string`   | —       | Maven user settings.xml 路径                      |
| `lsp.jdtls.maven.globalSettings` | `string`   | —       | Maven global settings.xml 路径                    |
| `file.run_cmd`                   | `table`    | `{}`    | 按文件类型映射的运行命令                          |

### Header 文件头模板

文件头模板由 `lua/configs/header.lua` 自动管理，新文件创建时自动插入。

**内置模板（14 种语言）：**

| 文件类型     | 模板语言                                    |
| ------------ | ------------------------------------------- |
| `python`     | Python docstring                            |
| `lua`        | `--` 行注释                                 |
| `javascript` | `/** */` 块注释 (JSX/TSX 也适用)            |
| `java`       | Javadoc 风格，含 `package` / `public class` |
| `kotlin`     | Javadoc 风格，含 `package` / `class`        |
| `scala`      | Javadoc 风格，含 `package` / `class`        |
| `go`         | `//` 行注释，含 `package`                   |
| `csharp`     | `///` XML 注释，含 `namespace` / `class`    |
| `c`          | `/* */` 块注释 (C++ 也适用)                 |
| `rust`       | `//` 行注释                                 |
| `ruby`       | `#` 行注释                                  |
| `bash`       | `#` 行注释 (sh/zsh 也适用)                  |
| `swift`      | `//` 行注释                                 |
| `zig`        | `//` 行注释                                 |

**ft_map 别名：** 以下文件类型自动映射到同名模板，无需单独配置：

| 原始文件类型      | 映射到       |
| ----------------- | ------------ |
| `typescript`      | `javascript` |
| `javascriptreact` | `javascript` |
| `typescriptreact` | `javascript` |
| `cpp`             | `c`          |
| `sh`              | `bash`       |
| `zsh`             | `bash`       |

**支持的占位符：**

| 占位符        | 说明                                                  |
| ------------- | ----------------------------------------------------- |
| `{USER}`      | 系统用户名（`$USER` / `$USERNAME`）                   |
| `{DATE}`      | 文件创建日期，默认格式 `%Y-%m-%d`                     |
| `{TIME}`      | 文件创建时间，默认格式 `%H:%M:%S`                     |
| `{DATE:fmt}`  | 自定义日期格式，如 `{DATE:%Y/%m/%d}`                  |
| `{TIME:fmt}`  | 自定义时间格式，如 `{TIME:%H:%M}`                     |
| `{FILE_NAME}` | 文件名（不含扩展名）                                  |
| `{CLASS}`     | 类名（默认同文件名，Java/Kotlin/Scala/C# 模板使用）   |
| `{PACKAGE}`   | 根据文件路径自动推导的包名/命名空间（为空时整行删除） |

**Package 自动推导：** Java/Kotlin/Scala/Go/C# 文件根据文件路径自动推导 `package` / `namespace`：

| 语言   | 项目标记文件                           | 源码目录          |
| ------ | -------------------------------------- | ----------------- |
| Java   | `pom.xml`, `build.gradle`              | `src/main/java`   |
| Kotlin | `pom.xml`, `build.gradle(.kts)`        | `src/main/kotlin` |
| Scala  | `pom.xml`, `build.gradle`, `build.sbt` | `src/main/scala`  |
| Go     | `go.mod`                               | `.`               |
| C#     | `*.csproj`, `*.sln`                    | `.`               |

**自定义模板：** 在 `settings.toml` 中添加 `[header]` 节覆盖任意语言模板：

```toml
[header]
python = '''\
# custom header
# author: {USER}
# description: (TODO)
'''
javascript = '''\
/**
 * custom header
 * @author {USER}
 */
'''
```

不存在的语言会自动忽略。只覆盖需要修改的模板即可，其余继续使用内置默认值。

**不再需要手写 tmpl 文件。** 旧版 `tmpls/` 目录可清理。

## 配置热重载

修改 `settings.toml` 后执行 `<leader>U` 重新加载配置，或 `<leader>ju` 仅刷新 jdtls 项目配置。

## 目录结构

```
~/.config/nvim/
├── after/
│   ├── ftplugin/java.lua   # Java 文件类型插件
│   ├── lsp/jdtls.lua       # jdtls LSP 配置
│   └── plugin/lsp.lua      # LSP 服务器启用
├── lua/
│   ├── configs/
│   │   ├── adapters/       # DAP 调试适配器（cpp, node）
│   │   └── java.lua        # Java LSP + Runner 核心模块
│   ├── core/               # 核心配置（options, mappings, autocmds）
│   ├── plugins/            # 插件配置
│   │   ├── edit/           # 编辑增强
│   │   ├── layout/         # 布局/UI
│   │   ├── docs/           # 文档
│   │   ├── tools/          # 工具集成
│   │   ├── ui/             # 界面美化
│   │   ├── navigation/     # 导航
│   │   └── workspace/      # 工作区
│   ├── settings.lua        # settings.toml 解析器
│   └── utils.lua           # 工具函数
├── snippets/               # 代码片段
├── init.lua                # 入口
└── settings.toml           # 用户配置
```

## PackUtils 插件管理

基于 Neovim 0.12 原生 `vim.pack` API，全部逻辑在 `lua/core/setup.lua`。

### Spec 声明

```lua
local specs = {
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/saghen/blink.cmp', version = 'v1.*' },
  { src = 'https://github.com/mason-org/mason.nvim', enabled = require('settings').mason.enable },
  { src = 'https://github.com/...', enabled = function() return vim.fn.executable('git') == 1 end },
}
```

`version` 支持 semver range（`v1.*`）或 git 分支名（`main`）。`enabled` 支持 `boolean` 或 `function → boolean`。

### 加载和配置

```lua
PackUtils.load({
  name = 'blink.cmp',          -- 必填
  deps = { 'LuaSnip' },        -- 依赖（先于主插件挂载）
  build_cmd = ':TSUpdate',     -- 构建命令
}, function()
  require('blink.cmp').setup({ ... })
end)
```

### 构建系统

`build_cmd` 支持两种形式：

- `:vim-cmd` — 以 `:` 开头，在 Neovim 主线程执行（如 `:TSUpdate`）
- shell 命令 — 异步后台执行（如 `make`, `npm install`）

通过 `.build_done` stamp 文件防止重复构建。`PackChanged` autocmd 在插件更新后自动重新构建。

### 命令

| 命令                    | 说明                   |
| ----------------------- | ---------------------- |
| `:PkUpdate [plugin...]` | 更新插件，`!` 跳过确认 |
| `:PkStatus [plugin...]` | 查看版本状态（离线）   |

### 控制层级

| 参数              | false 时效果                         |
| ----------------- | ------------------------------------ |
| `enabled` (specs) | 不下载、不 `packadd`、不 `config_fn` |
| `enabled` (load)  | 不 `packadd`、不 `config_fn`         |
| `loaded`          | 仅 `packadd`，不执行 `config_fn`     |

## 快捷键

### 通用

| 快捷键      | 功能           |
| ----------- | -------------- |
| `<leader>U` | 重新加载配置   |
| `<leader>R` | 重启 Neovim    |
| `Q`         | 强制退出       |
| `<esc>`     | 清除搜索高亮   |
| `s`         | Flash 代码跳转 |
| `y`         | 高亮复制区域   |

### 窗口管理

| 快捷键        | 功能                |
| ------------- | ------------------- |
| `sv`          | 水平分屏            |
| `sp`          | 垂直分屏            |
| `sc`          | 关闭当前窗口        |
| `so`          | 关闭其他窗口        |
| `s=`          | 窗口等宽            |
| `<c-h/j/k/l>` | 窗口跳转            |
| `<c-m-j/k>`   | 当前行上/下移动     |
| `<m-h/j/k/l>` | Insert 模式光标移动 |

### Buffer

| 快捷键       | 功能            |
| ------------ | --------------- |
| `<tab>`      | 下一个 buffer   |
| `<s-tab>`    | 上一个 buffer   |
| `<leader>bc` | 关闭当前 buffer |
| `<leader>bC` | 关闭其他 buffer |

### 文件搜索

| 快捷键       | 功能               |
| ------------ | ------------------ |
| `<leader>ff` | 智能文件选择       |
| `<leader>fb` | 查找 buffer        |
| `<leader>fo` | 最近文件           |
| `<leader>fw` | 文件内搜索         |
| `<leader>fW` | 当前 buffer 内搜索 |
| `<leader>fh` | 帮助文档搜索       |
| `<leader>fk` | 快捷键搜索         |
| `<leader>fi` | 图标搜索           |
| `<leader>ft` | TODO 注释搜索      |
| `<leader>fd` | 当前 buffer 诊断   |
| `<leader>fs` | 当前文件符号       |
| `<leader>fS` | 工作区符号         |

### 终端

| 快捷键       | 功能         |
| ------------ | ------------ |
| `<c-t>`      | 浮动终端开关 |
| `<leader>rf` | 运行当前文件 |

### Git

| 快捷键       | 功能            |
| ------------ | --------------- |
| `<leader>gb` | 切换 blame 显示 |
| `<leader>gB` | 当前行 blame    |

### 编辑

| 快捷键              | 功能         |
| ------------------- | ------------ |
| `<leader>/`         | 行注释       |
| `<leader><leader>/` | 块注释       |
| `<leader>cc`        | 命名风格转换 |
| `<m-a>`             | 全选         |
| `<m-s>`             | 选中括号内容 |
| `<c-s>`             | 替换光标词   |

### LSP

| 快捷键       | 功能               |
| ------------ | ------------------ |
| `gd`         | 跳转到定义         |
| `gD`         | 跳转到定义（分屏） |
| `gi`         | 跳转到实现         |
| `ge`         | 跳转到下一个诊断   |
| `grr`        | 查找引用           |
| `K`          | 悬浮文档           |
| `<a-cr>`     | 代码操作           |
| `<leader>rn` | 重命名符号         |
| `<leader>th` | 切换内联提示       |

### DAP 调试

| 快捷键                | 功能          |
| --------------------- | ------------- |
| `<leader>du` / `<F1>` | 切换 DAP UI   |
| `<leader>ds` / `<F2>` | 启动/继续     |
| `<leader>di` / `<F3>` | 步入          |
| `<leader>do` / `<F4>` | 步过          |
| `<leader>dO` / `<F5>` | 步出          |
| `<leader>dr` / `<F6>` | 重新开始      |
| `<leader>dQ` / `<F7>` | 终止          |
| `<leader>db`          | 断点          |
| `<leader>dB`          | 条件断点      |
| `<leader>dD`          | 清除所有断点  |
| `<leader>dc`          | 运行到光标    |
| `<leader>dh`          | 悬浮调试信息  |
| `<leader>dq`          | 关闭 DAP 会话 |
| `<leader>dR`          | 切换 REPL     |

### Java

| 快捷键        | 命令               | 功能                |
| ------------- | ------------------ | ------------------- |
| `<leader>jc`  | `JavaCompile`      | jdtls 编译工作区    |
| `<leader>ju`  | `JavaUpdateConfig` | 刷新项目配置        |
| `<leader>jr`  | `JavaRunMain`      | 运行 main class     |
| `<leader>jd`  | `JavaDebugMain`    | DAP 调试 main class |
| `<leader>js`  | `JavaStopMain`     | 停止运行            |
| `<leader>jl`  | `JavaToggleLogs`   | 切换运行日志        |
| `<leader>jtc` | `JavaTestClass`    | 运行测试类          |
| `<leader>jtm` | `JavaTestMethod`   | 运行测试方法        |

### Claude Code

| 快捷键       | 功能            |
| ------------ | --------------- |
| `<leader>ac` | 打开 Claude     |
| `<leader>af` | 聚焦 Claude     |
| `<leader>ar` | 恢复对话        |
| `<leader>aC` | 继续对话        |
| `<leader>am` | 选择模型        |
| `<leader>aq` | 关闭 Claude     |
| `<leader>ab` | 添加当前 buffer |
| `<leader>as` | 发送到 Claude   |
| `<leader>aa` | 接受 diff       |
| `<leader>ad` | 拒绝 diff       |

### HTTP (Kulala)

| 快捷键       | 功能            |
| ------------ | --------------- |
| `<c-cr>`     | 发送请求        |
| `<leader>Rs` | 发送请求        |
| `<leader>Ra` | 发送所有请求    |
| `<leader>Rb` | 打开 Scratchpad |

### 翻译

| 快捷键       | 模式 | 功能       |
| ------------ | ---- | ---------- |
| `<leader>tt` | N/V  | 浮动翻译   |
| `<leader>tr` | N/V  | 翻译并替换 |

### 其他工具

| 快捷键       | 功能                          |
| ------------ | ----------------------------- |
| `<leader>ip` | 图片粘贴（剪贴板 → Markdown） |
| `<leader>ve` | Python venv 选择              |
| `<leader>nf` | 新建文件                      |
| `<leader>pf` | 项目搜索                      |
| `<leader>ph` | 项目历史                      |
| `<leader>pp` | 加载项目 session              |
| `<leader>co` | URL 打开                      |
