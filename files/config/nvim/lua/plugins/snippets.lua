-- ============================================
-- 代码片段引擎：LuaSnip
-- 配合 blink.cmp 使用，提供可展开的代码模板
-- 例如输入 for<Tab> 自动展开成 for 循环
-- ============================================

return {
  "L3MON4D3/LuaSnip",
  build = "make install_jsregexp", -- 编译正则支持（用于片段转换）
  keys = function()
    return {} -- 禁用默认快捷键（交给 blink.cmp 处理）
  end,
  opts = {
    history = true, -- 记住历史片段
    updateevents = "TextChanged,TextChangedI", -- 输入变化时更新
  },
}
