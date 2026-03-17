# Comment Plugin Migration Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Comment.nvim with ts-comments.nvim while preserving existing keybindings.

**Architecture:** Single file modification to swap the plugin and configure keymaps that delegate to ts-comments.nvim's built-in gc/gb operators.

**Tech Stack:** Neovim 0.12+, vim.pack, ts-comments.nvim, nvim-treesitter

---

## File Structure

| File | Action | Purpose |
|------|--------|---------|
| `lua/plugins/edit/comment.lua` | Modify | Replace plugin declaration and add keymaps |

---

## Chunk 1: Plugin Migration

### Task 1: Update comment.lua

**Files:**
- Modify: `lua/plugins/edit/comment.lua`

- [ ] **Step 1: Replace file contents with new plugin and keymaps**

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

- [ ] **Step 2: Commit the change**

```bash
git add lua/plugins/edit/comment.lua
git commit -m "feat: replace Comment.nvim with ts-comments.nvim

- Use treesitter-based comment detection
- Preserve <leader>/ and <leader><leader>/ keybindings
- Map to ts-comments.nvim's gc/gb operators

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Verification

After implementation, verify manually in Neovim:

1. Run `:vim.pack.update()` to install ts-comments.nvim and remove Comment.nvim
2. Restart Neovim
3. Open a lua file, test `<leader>/` toggles line comment
4. Open a lua file, test `<leader><leader>/` toggles block comment
5. Open other file types (java, ini) to verify correct comment formats