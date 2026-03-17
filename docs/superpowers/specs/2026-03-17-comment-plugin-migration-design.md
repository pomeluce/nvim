# Neovim 注释插件迁移设计

## 背景

Comment.nvim 已两年未维护，与其他插件存在兼容性问题。Neovim nightly (0.12+) 用户需要替代方案。

## 决策

使用 ts-comments.nvim 替代 Comment.nvim。

### 选择理由

- 基于 treesitter，自动识别注释格式
- 活跃维护，兼容性好
- 轻量，无额外依赖
- 已有 nvim-treesitter 依赖

## 快捷键映射

保持与原配置一致的快捷键风格：

| 模式 | 快捷键 | 功能 |
|------|--------|------|
| Normal | `<leader>/` | 切换当前行注释 |
| Normal | `<leader><leader>/` | 切换块注释 |
| Visual | `<leader>/` | 切换选中行注释 |
| Visual | `<leader><leader>/` | 切换选中区域块注释 |

## 实现

修改 `lua/plugins/edit/comment.lua`：

1. 移除 Comment.nvim 插件声明
2. 添加 ts-comments.nvim 插件声明
3. 配置快捷键映射

### 代码结构

```lua
vim.pack.add({
  { src = 'https://github.com/folke/ts-comments.nvim' },
})

-- 快捷键配置
local map = vim.keymap.set

-- 行注释
map('n', '<leader>/', 'gcc', { remap = true, desc = 'Toggle line comment' })
map('v', '<leader>/', 'gc', { remap = true, desc = 'Toggle line comment' })

-- 块注释
map('n', '<leader><leader>/', 'gbc', { remap = true, desc = 'Toggle block comment' })
map('v', '<leader><leader>/', 'gb', { remap = true, desc = 'Toggle block comment' })
```

## 依赖

- nvim-treesitter（已安装）
- ts-comments.nvim（新增）

## 迁移步骤

1. 修改 `lua/plugins/edit/comment.lua`
2. 删除 `nvim-pack-lock.json` 中的 Comment.nvim 条目（通过 `vim.pack.update` 自动处理）
3. 重启 Neovim，插件自动安装

## 验证

1. 打开 lua 文件，测试 `<leader>/` 行注释
2. 打开 lua 文件，测试 `<leader><leader>/` 块注释
3. 打开其他文件类型（如 java、ini），验证注释格式正确