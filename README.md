<div align='center'>

# AKIRVIM

</div>

- [使用说明](#使用说明)
- [目录结构](#目录结构)

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
│   ├── plugins
│   └── utils.lua
├── nvim-pack-lock.json
├── README.md
└── snippets
```
