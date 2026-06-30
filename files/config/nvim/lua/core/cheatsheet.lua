-- 个人快捷键速查浮动窗口
-- 新增快捷键时顺手在对应分类加一行即可
-- 格式：{ "按键", "说明（模式）" }

local M = {}

local sections = {
  { "行操作", {
    { "J（可视）", "下移选中行" },
    { "K（可视）", "上移选中行" },
  } },
  {
    "基础操作",
    {
      { "jk", "退出插入模式（i）" },
      { "jk", "退出终端模式（t）" },
      { "<C-s>", "保存文件（n,i）" },
      { "<C-CR>", "下方新建空行（i）" },
      { "s", "Flash 跳转（n,x,o）" },
      { "S", "Flash Treesitter 选择（n,x,o）" },
    },
  },
  {
    "窗口操作",
    {
      { "<C-h/j/k/l>", "切换窗口" },
      { "<leader>sh", "水平分割" },
      { "<leader>sv", "垂直分割" },
      { "<leader>q", "关闭窗口" },
      { "<leader>wq", "保存并关闭" },
    },
  },
  {
    "缓冲区",
    {
      { "<S-h>", "上一个缓冲区" },
      { "<S-l>", "下一个缓冲区" },
      { "<leader>ba", "关闭其他缓冲区" },
      { "<leader>bd", "关闭当前缓冲区" },
    },
  },
  { "文件树", {
    { "<leader>e", "打开/关闭文件树" },
  } },
  {
    "搜索（Telescope）",
    {
      { "<leader>ff", "搜索文件名" },
      { "<leader>fg", "搜索文件内容" },
      { "<leader>fb", "切换缓冲区" },
      { "<leader>fh", "搜索帮助" },
      { "<leader>fd", "搜索个人文档" },
      { "<leader>fp", "搜索项目" },
      { "<leader>fc", "搜索 Neovim 配置" },
    },
  },
  {
    "代码导航（LSP）",
    {
      { "gd", "跳转到定义" },
      { "gR", "跳转到类型定义" },
      { "gr", "查找引用" },
      { "gi", "跳转到实现" },
      { "K", "悬停文档" },
      { "[d / ]d", "上一个/下一个诊断" },
    },
  },
  {
    "代码操作",
    {
      { "<leader>rn", "重命名符号" },
      { "<leader>ca", "代码操作" },
      { "<leader>F", "格式化代码" },
      { "<C-k>", "函数签名提示（i）" },
    },
  },
  {
    "补全（blink.cmp）",
    {
      { "Enter / Tab", "选中当前项" },
      { "<C-n> / <C-p>", "选择下一项/上一项" },
      { "<C-e>", "关闭补全菜单" },
      { "<C-u> / <C-d>", "文档翻页" },
    },
  },
  {
    "注释",
    {
      { "gcc", "注释/取消注释当前行（n）" },
      { "gc", "注释/取消注释选中（x）" },
    },
  },
  {
    "调试（DAP）",
    {
      { "<leader>dl", "重跑上次调试" },
      { "<leader>db", "断点列表（telescope）" },
      { "<leader>dB", "条件断点" },
      { "<leader>dL", "日志断点" },
      { "<leader>dC", "清除所有断点" },
      { "<F5>", "开始调试 / 继续" },
      { "<F9>", "切换断点" },
      { "<F10>", "单步跳过" },
      { "<F11>", "单步进入" },
      { "<F12>", "单步跳出" },
    },
  },
  {
    "终端（toggleterm）",
    {
      { "<leader>tt", "切换浮动终端" },
      { "<leader>th", "水平分割终端" },
      { "<leader>tv", "垂直分割终端" },
    },
  },
  {
    "Java",
    {
      { "<leader>co", "Java 代码操作" },
      { "<leader>ot", "整理 import" },
      { "<F5>", "Java 调试（输入主类名）" },
    },
  },
  {
    "自定义命令",
    {
      { ":R", "重载当前 Lua 配置文件" },
      { ":A", "打开欢迎页" },
      { ":Projects", "打开项目列表" },
      { ":LspInfo", "查看 LSP 客户端状态" },
      { ":LspLog", "打开 LSP 日志" },
      { ":JavaInit", "初始化 Java 项目结构" },
      { ":JavaRun", "运行当前 Java 单文件" },
    },
  },
}

function M.show()
  local lines = {}
  for _, sec in ipairs(sections) do
    table.insert(lines, "")
    table.insert(lines, "  " .. sec[1])
    table.insert(lines, "  " .. string.rep("─", 50))
    for _, item in ipairs(sec[2]) do
      table.insert(lines, string.format("  %-20s  %s", item[1], item[2]))
    end
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local width = 56
  local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.55))
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
    title = " 快捷键速查 ",
    title_pos = "center",
  })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
end

return M
