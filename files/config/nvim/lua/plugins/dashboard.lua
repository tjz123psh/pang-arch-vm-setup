-- ============================================
-- 启动欢迎页：alpha-nvim
-- Neovim 启动时显示的漂亮界面
-- 有快捷键可以直接打开常用功能
-- ============================================

return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  cmd = "Alpha",

  opts = function()
    local dashboard = require("alpha.themes.dashboard")

    -- ASCII 艺术字 Logo（NEovIM）
    local logo = {
      "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
      "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
      "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
      "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
      "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
      "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
    }
    dashboard.section.header.val = logo

    -- 快捷按钮
    dashboard.section.buttons.val = {
      dashboard.button("f", "  查找文件", "<cmd>Telescope find_files<cr>"),
      dashboard.button("r", "  最近文件", "<cmd>Telescope oldfiles<cr>"),
      dashboard.button("c", "  Neovim 配置", "<cmd>Telescope find_files cwd=~/.config/nvim<cr>"),
      dashboard.button("p", "  项目列表", "<cmd>Projects<cr>"),
      dashboard.button("n", "  新建文件", "<cmd>ene <bar> startinsert<cr>"),
      dashboard.button("q", "  退出", "<cmd>qa<cr>"),
    }

    -- 页脚
    local version = vim.version()
    dashboard.section.footer.val = {
      "",
      string.format("  Neovim %d.%d.%d  |  %s  ", version.major, version.minor, version.patch, vim.fn.getcwd()),
    }
    dashboard.section.footer.opts.hl = "Type"

    -- 设置按钮颜色
    for _, btn in ipairs(dashboard.section.buttons.val) do
      btn.opts.hl = "Label"
      btn.opts.hl_shortcut = "Keyword"
    end

    -- 布局：上边距 3 → Logo → 边距 2 → 按钮 → 边距 1 → 页脚
    dashboard.opts.layout = {
      { type = "padding", val = 3 },
      dashboard.section.header,
      { type = "padding", val = 2 },
      dashboard.section.buttons,
      { type = "padding", val = 1 },
      dashboard.section.footer,
    }

    return dashboard.opts
  end,
}
