-- ============================================
-- Neovide GUI 专用配置
-- 只有在 Neovide 中启动时才会加载
-- ============================================

if not vim.g.neovide then
  return
end

-- 缩放比例（默认 1.0）
vim.g.neovide_scale_factor = 1.0

-- 窗口不透明度（0.8 = 80% 不透明，20% 透出桌面）
vim.g.neovide_opacity = 0.80

-- 光标特效风格
vim.g.neovide_cursor_vfx_mode = "railgun"

-- 设置字体（Linux 下优先使用 JetBrainsMono Nerd Font）
local font = "JetBrainsMono Nerd Font:h12"
if vim.fn.has("linux") == 1 and vim.fn.executable("fc-match") == 1 then
  local matched = vim.fn.systemlist({ "fc-match", "JetBrainsMono Nerd Font" })[1] or ""
  if not matched:lower():find("jetbrains", 1, true) then
    font = "monospace:h12"
  end
end
vim.o.guifont = font

-- 刷新率（Hz）
vim.g.neovide_refresh_rate = 60

-- 窗口圆角
vim.g.neovide_corner_style = "round"

-- 打字光标动画
vim.g.neovide_cursor_short_animation_length = 0.13
