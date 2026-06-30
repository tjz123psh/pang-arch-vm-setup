-- ============================================
-- 全局快捷键映射
-- 格式：map("模式", "按键", "命令", { desc = "说明" })
-- 模式：n=普通, i=插入, v=可视, x=选择, t=终端
-- ============================================

-- 自定义快捷键
local map = vim.keymap.set

-- 空格键自身不做任何事，只作为 leader 前缀等待后续按键
map("n", "<Space>", "<Nop>", { desc = "Leader 键" })

-- s、S 由 flash.nvim 接管：跳转到屏幕上任意可见位置
-- 插件自带映射：
--   <leader>e          neo-tree 文件树
--   <leader>tt/th/tv   toggleterm 终端
--   <leader>fp         Telescope 项目列表

-- jk 退出终端模式回到普通模式（:term 打开的终端）
-- 注意：终端内 j 后跟 k 会触发退出，注意误触
map("t", "jk", "<C-\\><C-n>", { desc = "退出终端模式" })

-- 窗口操作
map("n", "<C-h>", "<C-w>h", { desc = "切换到左边窗口" })
map("n", "<C-l>", "<C-w>l", { desc = "切换到右边窗口" })
map("n", "<C-j>", "<C-w>j", { desc = "切换到下边窗口" })
map("n", "<C-k>", "<C-w>k", { desc = "切换到上边窗口" })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = "水平切分窗口" })
map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "垂直切分窗口" })

-- 文件操作快捷键
map("n", "<C-s>", "<cmd>write<cr>", { desc = "保存当前文件" })
map("i", "<C-s>", "<C-o>:write<cr>", { desc = "保存当前文件（插入模式）" })
map("i", "<C-CR>", "<Esc>o", { desc = "在下方新建空行，继续编辑" })
map("n", "<leader>fc", "<cmd>Telescope find_files cwd=~/.config/nvim<cr>", { desc = "搜索 Neovim 配置文件" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "关闭当前窗口" })
map("n", "<leader>ba", "<cmd>BufferLineCloseOthers<cr>", { desc = "关闭其他缓冲区" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "关闭当前缓冲区（文件）" })
map("n", "<leader>wq", "<cmd>wq<cr>", { desc = "保存并关闭" })

-- 可视模式下移动选中行：J 下移，K 上移
map("x", "J", function()
  vim.cmd("'<,'>move '>+1")
  vim.cmd("normal! gv=gv")
end, { desc = "下移选中行" })
map("x", "K", function()
  vim.cmd("'<,'>move '<-2")
  vim.cmd("normal! gv=gv")
end, { desc = "上移选中行" })

local cheatsheet = require("core.cheatsheet")
map("n", "<leader>hk", cheatsheet.show, { desc = "快捷键速查" })
