## RifyVim IDE

<!-- markdown-toc GFM -->

* [使用说明](#使用说明)
* [目录结构](#目录结构)
* [基础快捷键](#基础快捷键)
* [插件快捷键](#插件快捷键)

<!-- markdown-toc -->

### 使用说明

1. backup 原有 nvim 配置, 并删除 nvim 数据目录

```
cp ~/.config/nvim /you/backup/path/nvim-bak

rm -rf ~/.local/share/nvim/
```

2. 所需环境

```
yay -S python-pynvim the_silver_searcher fd bat ripgrep unzip luarocks
```

3. 拉取 RifyVim 配置

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
├──colors
├──lua
│   ├──user
│   │   ├──config
│   │   ├──core
│   │   ├──dap
│   │   ├──fmt
│   │   ├──lsp
│   │   ├──plugins
│   │   └──setup.lua
│   └──user-config.lua # 用户自定义配置
├──init.lua
├──lazy-lock.json
├──LICENSE
├──neoconf.json
├──README.md
├──snippets
├──.gitignore
├──.prettierrc.json
├──.rustfmt.toml
├──.stylua.toml
└──.taplo.toml
```

### 基础快捷键

| mode    | 快捷键           | 说明                         |
| ------- | ---------------- | ---------------------------- |
| n, v    | ;                | 进入 cmd 模式                |
| i       | jk               | Esc                          |
| n       | S                | 文件保存                     |
| n       | Q                | 强制退出                     |
| n       | alt + a          | 选中全部内容                 |
| n       | alt + s          | 选中括号内的内容             |
| n, v    | ctrl + s         | 全局替换                     |
| n       | n + h            | 取消搜索高亮                 |
| n       | space            | 行首行尾跳转                 |
| n, v    | 0                | object 内跳转                |
| n       | s + v            | 水平分屏, 并跳转到下一个窗口 |
| n       | s + p            | 垂直分屏, 并跳转到下一个窗口 |
| n       | s + c            | 关闭当前窗口                 |
| n       | s + o            | 关闭其他窗口                 |
| n       | ctrl + h         | 向左跳转窗口                 |
| n       | ctrl + l         | 向右跳转窗口                 |
| n       | ctrl + j         | 向下跳转窗口                 |
| n       | ctrl + k         | 向上跳转窗口                 |
| n       | ctrl + space     | picker 切换窗口              |
| n       | s + =            | 设置所有窗口大小相等         |
| n       | s + .            | 向左扩展窗口                 |
| n       | s + ,            | 向右扩展窗口                 |
| n       | s + j            | 向底部扩展窗口               |
| n       | s + k            | 向顶部扩展窗口               |
| n       | s + s            | 切换下一个 buffer            |
| n       | leader + c       | 关闭当前窗口                 |
| n, v, i | alt + left       | 向左切换 buffer              |
| n, v, i | alt + right      | 向右切换 buffer              |
| n, x, o | s                | flash 跳转                   |
| n, x, o | f + s            | flash 选中                   |
| o       | r                | flash 跳转复制               |
| o, x    | f + r            | flash 选中复制               |
| n       | g + a            | 跳转到上次编辑位置           |
| n       | g + ;            | 行尾添加分号                 |
| i       | alt + h          | 插入模式向左移动             |
| i       | alt + l          | 插入模式向右移动             |
| i       | alt + j          | 插入模式向下移动             |
| i       | alt + k          | 插入模式向上移动             |
| n, i, v | ctrl + shift + j | 向上移动行                   |
| n, i, v | ctrl + shift + k | 向下移动行                   |
| v       | J                | 向上移动行                   |
| v       | K                | 向下移动行                   |
| v       | <                | 向左缩进代码                 |
| v       | >                | 向右缩进代码                 |
| v       | tab              | 向右缩进代码                 |
| v       | shift + tab      | 向左缩进代码                 |
| n       | z + z            | 切换显示代码折叠             |
| v       | z                | 添加代码折叠                 |
| n       | C                | 查看当前行 git 提交历史      |
| n       | \ + g            | 切换显示当前行 git 提交历史  |
| v       | t                | 驼峰转换                     |
| v       | T                | 驼峰转换                     |
| n, i    | F5               | 执行代码                     |
| n       | leader + f + t   | 全局搜索文本                 |
| n       | leader + f + f   | 查找文件                     |
| n       | leader + f + b   | 查看已打开的 buffer          |
| n       | leader + f + w   | 在当前 buffer 查找文本       |
| n       | leader + f + g   | 查看 git diff 文件           |
| n       | leader + f + h   | 查看历史文件                 |
| n       | leader + f + p   | 查看项目列表                 |
| n       | H                | 查看语法高亮                 |
| n       | R                | 刷新高亮                     |
| n       | T                | 打开文件树                   |
| n       | leader + s + p   | 加载工作空间项目列表         |
| n       | leader + e + s   | 编辑 vim 配置                |
| n       | leader + e + k   | 编辑快捷键                   |
| n       | leader + d + /   | 文档注释                     |
| n       | leader + r + s   | 恢复项目会话                 |
| n       | F2               | start breakpoint debug       |
| n       | F10              | step over breakpoint debug   |
| n       | F11              | step into breakpoint debug   |
| n       | F12              | step out breakpoint debug    |
| n       | leader + d + b   | toggle breakpoint debug      |
| n       | leader + B       | set breakpoint debug         |
| n       | leader + d + m   | log point breakpoint debug   |
| n       | leader + d + r   | open debug repl              |
| n       | leader + d + l   | run last debug               |
| n, v    | leader + d + h   | debug hover                  |
| n, v    | leader + d + p   | debug preview                |
| n       | leader + d + f   | float show debug frames      |
| n       | leader + d + s   | float show debug scopes      |
| n       | leader + r + n   | 重命名                       |
| n       | g + d            | 跳转到定义                   |
| n       | g + i            | 跳转到实现                   |
| n       | g + D            | 跳转到声明                   |
| n       | g + e            | 跳转到错误                   |
| n       | g + t            | 跳转到类型定义               |
| n       | g + r            | 跳转到引用                   |
| n       | leader + s + s   | structure 列表               |
| n       | K                | hover documents              |
| n, v    | alt + return     | code action                  |
| n       | leader + f + m   | 代码格式化                   |

### 插件快捷键

<details>
<summary style="cursor: pointer;">floaterm 浮动终端</summary>

| mode | 快捷键   | 说明                   |
| ---- | -------- | ---------------------- |
| n    | ctrl + b | 打开数据库 ui          |
| n    | ctrl + p | 打开 ranger 文件管理器 |
| n    | ctrl + t | 打开浮动终端           |

</details>

<details>
<summary style="cursor: pointer;">comment 注释</summary>

| mode  | 快捷键              | 说明     |
| ----- | ------------------- | -------- |
| n, v  | leader + /          | 单行注释 |
| n , v | leader + leader + / | 多行注释 |

</details>

<details>
<summary style="cursor: pointer;">tabout 跳出</summary>

| mode | 快捷键   | 说明          |
| ---- | -------- | ------------- |
| i    | ctrl + t | tab 功能      |
| i    | ctrl + d | 反向 tab 功能 |

</details>
