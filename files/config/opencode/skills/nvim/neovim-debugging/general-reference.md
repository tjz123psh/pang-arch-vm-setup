# 通用排查参考

通用 Neovim 排查信息，不绑定本机特定配置。

---

## 一、信息收集

### 核心原则

能程序收集的先收集，再问用户。

### 可程序收集的信息

```bash
# 系统信息
nvim --version | head -1
uname -a

# 配置状态
nvim --headless -c "lua print(vim.o.tabstop)" -c "qa" 2>&1
nvim --headless -c "verbose map <leader>ff" -c "qa" 2>&1

# 插件状态
nvim --headless -c "lua for name, _ in pairs(require('lazy.core.config').plugins) do print(name) end" -c "qa" 2>&1

# 插件版本
git -C ~/.local/share/nvim/lazy/plugin-name rev-parse --short HEAD

# 文件内容
rg -n "which-key" ~/.config/nvim/lua/
```

### 需要问用户的信息

- 交互行为："按 X 时看到什么？"
- 复现步骤："在什么文件、做了什么之后出错？"
- 偏好："你希望保留哪种行为？"

### 提问原则

- 问具体、封闭的问题，不要问"你的配置是什么"
- 说明为什么问
- 提供可复制的命令
- 用对比问题缩小范围

---

## 二、通用插件排查

### lazy.nvim

**插件未加载**：
```lua
:Lazy                   -- 搜索插件名
:Lazy load plugin-name  -- 强制加载
```
检查 lazy 加载条件：`event`、`cmd`、`ft`、`keys`、`lazy = false`

**opts vs config**：
- `opts = {}` → 自动传入 setup()
- `config = function(_, opts)` → 需要手动调 setup()
- 常见错误：定义了 `config` 但没调 `setup()`

**依赖加载**：
```lua
dependencies = { "dep-plugin" }  -- 在主插件之前加载
```

### which-key.nvim

**弹窗不出现**：
```lua
:lua require('which-key').show('<leader>')   -- 手动触发
:lua require('which-key').show('\\')         -- localleader
```
手动成功但自动失败 → trigger 配置问题。

**映射不显示**：
```lua
:nmap <leader>         -- 列出所有 leader 映射
:verbose map <key>     -- 显示定义位置
```

映射通过以下方式注册：
1. `which-key.add()` (v3) 或 `register()` (v2)
2. `opts.spec`
3. `vim.keymap.set` 带 `desc` 选项

### LSP

**服务器未附加**：
```vim
:LspInfo
:LspLog
:checkhealth vim.lsp
```

常见原因：服务器未安装（`:Mason`）、文件类型未识别（`:set ft?`）、无 root 目录（需 `.git` / `package.json` 等）。

**已附加但无功能**：
```lua
:lua print(vim.inspect(vim.lsp.get_clients()[1].server_capabilities))
```

**无补全**：检查 `blink.cmp` 是否配置了 `lsp` 源。

**无诊断**：检查 `vim.diagnostic.is_enabled()`。

### Treesitter

**无高亮**：
```vim
:TSInstallInfo
:InspectTree
```
Parser 未安装 → `:TSInstall {lang}`，过时 → `:TSUpdate`。

**查询错误**：
```
query: invalid node type at position X for language Y
```
Parser 更新后节点名变了 → 更新插件或锁定 parser 版本。

### Telescope

**Picker 未找到**：
```lua
:lua print(vim.inspect(vim.tbl_keys(require('telescope.builtin'))))
```

**扩展未加载**：
```lua
require('telescope').setup({})
require('telescope').load_extension('fzf')  -- 必须在 setup 之后
```

**性能慢**：检查是否用了原生 fzf sorter，关 preview 测试。

### blink.cmp

**无补全弹出**：
```lua
:lua print(vim.inspect(require('blink.cmp.config').sources.default))
:lua require('blink.cmp').show()
```

**LSP 补全缺失**：确认 `lsp` 在 sources 中，并且 LSP capabilities 来自 `blink.get_lsp_capabilities()`。

**代码片段不展开**：
```lua
:lua print(require('luasnip'))
```

### Snacks.nvim

Picker 错误 `attempt to index local 'opts' (a nil value)` → 调用方没传 opts 表，在堆栈中找到调用方传 `{}`。

---

## 三、反模式

### 应避免

| 反模式 | 问题 | 推荐做法 |
|--------|------|----------|
| `vim.cmd("set number")` | 额外 VimScript 执行 | `vim.o.number = true` |
| `vim.api.nvim_set_keymap` | 底层 API，不支持 Lua 函数 RHS | `vim.keymap.set` |
| `autocmd` 在 vim.cmd 中 | 不原生，难管理 | `vim.api.nvim_create_autocmd` |
| 到处用 `pcall` | 隐藏错误 | 仅在入口点用 pcall |
| lazy spec 顶部 `require` | 立即加载插件 | 移入 `config` 函数内 |

### 常见错误

```lua
-- 错误：立即执行
config = require("telescope").setup({})

-- 正确：延迟执行
config = function()
  require("telescope").setup({})
end

-- 错误：引用未加载的插件
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    require("conform").format()  -- 可能未加载
  end,
})

-- 正确：让插件管理自己的事件
{
  "stevearc/conform.nvim",
  event = "BufWritePre",
  opts = { format_on_save = true },
}
```

---

## 四、诊断输出格式

```markdown
## 诊断

**症状**：[用户报告的问题]
**根因**：[实际原因]
**证据**：[如何确定的]

## 解决方案
[分步修复]

## 预防
[以后怎么避免]
```

---

## 五、调优参考

### 启动时间

```bash
nvim --startuptime /tmp/startup.log +q
sort -t: -k2 -n /tmp/startup.log | tail -20  # 最慢的 20 项
```

标准：<100ms 快、100–300ms 可接受、>300ms 需调查、>1000ms 很慢。

### 通用性能建议

- 非必要插件用 `event = "VeryLazy"` 延迟
- 用文件类型触发 `ft = "lua"` 而非全文件
- 频繁触发的事件（BufEnter）不做重操作
- 大语言服务器用 mason-lspconfig 按需安装
