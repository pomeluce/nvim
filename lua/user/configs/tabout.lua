local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  return {
    -- 设置 tab 键, 设置 '' 以禁用
    tabkey = '<Tab>',
    -- 设置回退 tab 键, 设置 '' 以禁用
    backwards_tabkey = '<S-Tab>',
    -- 如果如法跳出选项卡, 则移动内容
    act_as_tab = true,
    -- 如果如法跳出选项卡, 则反向移动内容
    act_as_shift_tab = false,
    -- tab 功能快捷键(mode: i)
    default_tab = '<C-t>',
    -- 反向 tab 快捷键(mode: i)
    default_shift_tab = '<C-d>',
    enable_backwards = true,
    -- 补全菜单打开时, 禁用跳出功能
    completion = true,
    tabouts = {
      { open = "'", close = "'" },
      { open = '"', close = '"' },
      { open = '`', close = '`' },
      { open = '(', close = ')' },
      { open = '[', close = ']' },
      { open = '{', close = '}' },
      { open = '<', close = '>' },
    },
    -- 设置为 true, 可以从字符串, 对象属性等的开头跳出
    ignore_beginning = true,
    exclude = {},
  }
end

return M
