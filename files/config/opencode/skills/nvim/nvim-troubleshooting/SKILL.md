---
name: nvim-troubleshooting
description: Neovim 配置过程遇到的问题与最终解决方案。改配置后发现新问题必须追加，重复问题以最新方案覆盖。配合 neovim-arch 使用。
---

# Neovim 配置问题排查记录

每次修改配置后必须将新问题追加到此处，重复问题以最新完全解决方案覆盖。

## 环境

| Neovim | 插件管理器 | 终端 | 系统 |
|--------|-----------|------|------|
| 0.12.3 | lazy.nvim | kitty (Wayland) | Arch Linux |

---

## 1. LSP

### 1.1 clangd root_dir 用新 API（Neovim 0.12+）

**问题**：`root_dir` 旧签名 `function(fname) → string`，0.12+ 要求 `function(bufnr, on_dir)`。

**解决**（`lua/plugins/lang/cpp.lua`）：
```lua
root_dir = function(bufnr, on_dir)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  if fname and #fname > 0 then
    on_dir(vim.fs.root(fname, { ".clangd", "compile_commands.json", "build/compile_commands.json", ".git" }) or vim.fn.getcwd())
  end
end,
```
关键：必须调 `on_dir(path)` 传回结果，不能 return；用 `vim.fs.root()` 替代手动遍历父目录。

### 1.2 Mason 重复启动 LSP 客户端

**问题**：mason-lspconfig 自动配置 + 手动 `vim.lsp.config` + `vim.lsp.enable` 导致每个 buffer 两个 LSP 客户端。

**解决**（`lua/plugins/lsp/init.lua`）：
```lua
automatic_enable = false, -- 手动管理，跳过自动启用
```
全靠 `config` 函数内的 `vim.lsp.config` + `vim.lsp.enable` 启动，mason 只负责安装。

### 1.3 LSP 配置从旧 API 迁移到 vim.lsp.config

**问题**：旧版用 `require("lspconfig.configs.X").default` 合并配置，0.12+ 改用 `vim.lsp.config` + `vim.lsp.enable`。

**解决**：`vim.lsp.config(server, config)` → `vim.lsp.enable(server)`。`vim.lsp.enable` 自动处理去重。

### 1.3.1 Mason 未初始化警告

**问题**：启动时出现 `mason.nvim has not been set up. Make sure to set up mason.nvim before mason-lspconfig.nvim.`。

**根因**：mason-lspconfig 的 setup 早于 mason.nvim setup。

**解决**（`lua/plugins/lsp/init.lua`）：
```lua
config = function(_, opts)
  require("mason").setup({ PATH = "prepend" })
  require("mason-lspconfig").setup(opts)
end
```
同时 `mason.lua` 保持 `lazy = false`。

### 1.3.2 Mason health 可选工具警告

**问题**：`:checkhealth mason` 提示 wget、luarocks、Ruby、Composer、PHP、Julia、pip 等缺失。

**判断**：这些是 Mason 对多语言生态的可选探测，不等同于当前 Neovim 配置故障。只要本配置需要的工具链可用即可：git/curl/unzip/tar/bash、node/npm、python、cargo、go、java/javac，以及 Mason 已安装的 LSP/DAP/formatter。

**处理**：不要为了清警告在 Neovim 配置中硬屏蔽；只有实际要安装对应生态的 Mason 包时，再补系统依赖。

### 1.4 jdtls 不由 lspconfig 管理

**问题**：jdtls 由 nvim-jdtls 独立管理，lspconfig 也试图启动会冲突。

**解决**（`lua/plugins/lsp/init.lua`）：
```lua
setup = {
  jdtls = function() return true end, -- 跳过
}
```

---

## 2. 插入模式退出（jk）

### 2.1 timeoutlen 与 jk 冲突

**问题**：`timeoutlen` 设高让 Space leader 能响应多键组合，但 `inoremap jk <Esc>` 导致每次按 `j` 都要等 timeoutlen 才显示字符。

**解决**：换 `better-escape.vim` 插件，监听按键时检查光标前字符，不依赖 `timeoutlen`。
```lua
-- lua/plugins/betterescape.lua
{
  "nvim-zh/better-escape.vim",
  event = "InsertEnter",
  config = function()
    vim.g.better_escape_shortcut = "jk"
    vim.g.better_escape_interval = 200
  end,
}
```
同时删掉 `keymaps.lua` 的 `inoremap jk <Esc>` 和 `autocmds.lua` 的 `timeoutlen` 切换逻辑。

---

## 3. 补全

### 3.1 blink.cmp 双空格触发导致空格延迟

**问题**：`["<Space><Space>"] = { "show", "hide" }` 使每次按空格都要等确认是否为第二个空格。

**解决**：删掉双空格映射，让 blink.cmp 打字时自动触发。

---

## 4. 调试（DAP，C++）

### 4.1 codelldb 未安装

**解决**：`:MasonInstall codelldb`。

### 4.2 DAP UI 闪开闪闭

**问题**：`stopOnEntry = false` 且未设断点时，程序直接跑完退出。

**解决**：保留 `stopOnEntry = false`，调试前 F9 设断点。不要 `stopOnEntry = true`（会停在 ld 的汇编代码中）。正确流程：
```
g++ -g test/Merge-sort.cpp -o bin/Merge-sort
# 打开源文件 → F9 设断点 → F5 输入 bin/程序名
```

### 4.3 "Invalid cursor line: out of range"

**原因**：源代码修改后未重新编译，debug info 与源文件不匹配。

**解决**：`g++ -g` 重新编译。

---

## 5. 调试（DAP，Java）

### 5.1 mainClass 必须为字符串

**问题**：`dap.run()` 将配置序列化为 JSON，函数无法序列化。

**解决**：`vim.fn.input("主类名: ")` 先求值为字符串，再传 `dap.run({ mainClass = 字符串 })`。

### 5.2 java-debug-adapter 必须作为 jdtls bundle 加载

**问题**：不能 `java -jar` 独立运行。

**解决**（`lua/plugins/lang/java.lua`）：
```lua
local java_debug_jar = vim.fn.glob(
  vim.fn.stdpath("data") .. "/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar")
if #java_debug_jar > 0 then
  vim.list_extend(opts.init_options.bundles, java_debug_jar)
end
```

### 5.3 Java 调试必须预先设断点

**问题**：java-debug-adapter 不像 codelldb 自动停在 main。

**解决**：F9 设断点，再 F5。

### 5.4 快捷键重复注册（schedule + autocmd）

**问题**：`ft = "java"` 懒加载导致当前 buffer 的 FileType 事件错过，所以同时用 `vim.schedule` + `FileType` autocmd 处理，导致 `<F5>`、`<leader>co`、`<leader>ot` 注册两次。

**解决**：提取 `setup_java_keys(bufnr)` 函数，两处共用。

---

## 6. UI 与延迟加载

### 6.1 shell = fish 导致构建命令异常

**问题**：`vim.o.shell = fish` 语法与 POSIX sh 不同，lazy.nvim 的 `build` 用 `sh -c` 执行报错。

**解决**：通过 `vim.fn.exepath("bash")` 找 bash，找不到时保留默认 shell。
```lua
vim.o.shell = vim.fn.exepath("bash") ~= "" and vim.fn.exepath("bash") or vim.o.shell
```

### 6.2 Noice 自身即可接管 vim.ui.input

Noice 的 `cmdline.format.input` 默认 `view = "cmdline_input"`，拦截 `vim.fn.input()` 后渲染为圆角浮动窗口，无需 dressing/snacks。`use_popups_for_input = false` 后 neo-tree 也走此路径。

**注意**：neo-tree 会在 prompt 末尾加 `\n`，导致 `cmdline_input` 判定 `use_input = false` → prompt 显示为行内文字而非标题，图标也隐藏。视觉影响可接受。

### 6.3 statusline/lualine 加载时机

**问题**：`event = "VeryLazy"` 使状态栏晚出现。

**解决**：`event = "UIEnter"`（UI 首次绘制后立即加载）。

### 6.4 可视模式 `J`/`K` 触发 noice 命令行闪框

**问题**：可视模式用 `:m '<-2<CR>gv=gv` 移动行，`: ` 进入命令行模式，noice 渲染为浮动窗口闪一下。

**解决**：改用 Lua 函数 + `vim.cmd` 直调，不走命令行 UI：
```lua
map("x", "J", function()
  vim.cmd("'<,'>move '>+1")
  vim.cmd("normal! gv=gv")
end, { desc = "向下移动选中行" })
map("x", "K", function()
  vim.cmd("'<,'>move '<-2")
  vim.cmd("normal! gv=gv")
end, { desc = "向上移动选中行" })
```
关键：`vim.cmd` 是 Lua API 调用，不经过命令行模式，noice 不拦截。

### 6.5 bufferline 强制关闭未保存 buffer

**问题**：`close_command = "bdelete! %d"` 会丢弃未保存修改。

**解决**：改成不带 bang：
```lua
close_command = "bdelete %d"
right_mouse_command = "bdelete %d"
```
这样有未保存修改时关闭会失败并提示。

---

## 7. 项目管理

### 7.1 project.nvim 使用已废弃 API

**问题**：`vim.lsp.buf_get_clients()` 在 0.10 废弃。

**解决**（`lua/plugins/project.lua`）：运行时 monkey-patch `find_lsp_root`，用 `vim.lsp.get_clients()` 替代。不改插件源文件（防 lazy.nvim dirty）。

### 7.2 project.nvim LSP root 为空

**问题**：某些 LSP client 没有 `client.config.root_dir`，project.nvim 取到 nil/空字符串会影响 CWD 切换。

**解决**：monkey-patch 中只在 `root_dir` 是非空字符串时返回，否则继续找下一个 client 或走 pattern 检测。

---

## 8. 系统

### 8.1 未使用的包检查

```bash
pacman -Qtdq
```

可选清理：确认列表无误后再执行 `sudo pacman -Rns $(pacman -Qtdq)`。

---

---

## 9. Java LSP（nvim-jdtls）

### 9.1 Neovim 0.12+ root_dir 函数不生效

**问题**：jdtls 只报语法错误，日志显示 `"No workspace folders or root uri was defined"`。

**根因**：`vim.lsp.start` 不解析函数式 `root_dir`（只在 `vim.lsp.enable` 的 `lsp_enable_callback` 中处理），而 `nvim-jdtls` 直接调 `vim.lsp.start`。函数式 root_dir 传入后一直未被求值，jdtls 收不到 rootUri，降级为 standalone 模式。

**旧代码**（`lua/plugins/lang/java.lua`）：
```lua
opts = {
  root_dir = function(path)
    return vim.fs.root(path, { "pom.xml", ... })
  end,
}
```

**解决**：不在 `opts` 中设 root_dir 函数，在 `config` 函数内预解析为字符串：
```lua
config = function(_, opts)
  local resolve_root = function(bufnr)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    if fname and #fname > 0 then
      return vim.fs.root(fname, { "pom.xml", "build.gradle", "build.gradle.kts", ".git", "src" })
        or vim.fn.getcwd()
    end
    return vim.fn.getcwd()
  end
  opts.root_dir = resolve_root(0)

  -- 后续文件也每次重新解析
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = function()
      opts.root_dir = resolve_root(0)
      jdtls.start_or_attach(opts)
    end,
  })
end
```

**注意事项**：
- Java 文件需在标准 Maven 目录结构（`src/main/java/`）或 Gradle 项目中才能获得完整语义分析
- 单文件目录下放最小 `pom.xml` + `src/main/java/` 即可触发完整报错

---

### 9.2 jdtls workspace_dir 跨项目不更新

**问题**：`-data` workspace_dir 只在 config 首次执行时算一次，`FileType` autocmd 只更新 `root_dir` 不更新 `cmd`，切 Java 项目时 jdtls 一直用第一个项目的 workspace。

**解决**（`lua/plugins/lang/java.lua`）：
- `cmd_base` 保存基础 cmd（不含 `-data`）
- `build_cmd(dir)` 函数每次重新拼装 `{ cmd_base, "-data", workspace_dir }`
- `start_jdtls(bufnr)` 统一入口：先调 `resolve_root()` 再调 `build_cmd()` 再 `start_or_attach()`
- autocmd 和 `vim.schedule` 都走 `start_jdtls`

---

## 10. 懒加载与优化

### 10.1 启动页第一次打开项目列表为空

**问题**：启动欢迎页点击“项目列表”时，第一次 Telescope 框内为空，第二次才显示项目。

**根因**：project.nvim 的历史读取是异步的；如果项目插件到第一次点击时才初始化，`Telescope projects` 创建 finder 时可能还没读完 `project_history`。另外，project.nvim 的 Telescope 扩展默认选择项目后会再打开一层 `find_files` picker；从 alpha 用 `:A` 返回后再次选择项目，嵌套 picker 状态容易卡住。

**解决**：
- project.lua 改为 `lazy = false`，启动时先初始化 project.nvim
- 保持 Telescope 扩展注册在 telescope.lua：`setup(opts)` 后 `pcall(require("telescope").load_extension, "projects")`
- 新增 `:Projects` 命令：先加载 project/telescope/neo-tree，再同步读取 project.nvim 历史文件，然后用自定义 Telescope picker 展示项目
- `:Projects` 默认回车只切换 cwd 并打开/刷新 neo-tree，不调用 `Telescope projects` 的默认嵌套 `find_files`
- 启动页 `p` 和 `<leader>fp` 都走 `:Projects`

### 10.1.1 项目切换后 neo-tree 仍停在 home

**问题**：从项目列表选中项目后，Telescope 已切到项目目录，但左侧 neo-tree 仍停在 `$HOME`。

**根因**：neo-tree `filesystem.bind_to_cwd = false` 时不会监听 cwd 变化；project.nvim 的项目切换只会更新 cwd。

**解决**（`lua/plugins/filetree.lua`）：
```lua
filesystem = {
  bind_to_cwd = true,
}
```
同时在 `lua/plugins/project.lua` 包装 `Project.set_pwd()`：原函数成功返回后，如果 neo-tree 已加载，则对 filesystem state 调 `manager.navigate(state, dir)`，主动把根目录刷新到项目目录。这样既保留 cwd 绑定，也避免 UI 事件时序导致文件树停在旧目录。

### 10.2 格式化超时偏短

**问题**：`format_on_save.timeout_ms = 500`，Java/C++/Rust 大项目容易超时。

**解决**：改为 `2000ms`（`lua/plugins/format.lua`）。

### 10.3 conform 只按 `<leader>F` 懒加载导致首次保存不格式化

**问题**：`format.lua` 只有 `keys = { "<leader>F" }`，lazy.nvim 会把 conform 变成按键懒加载；`format_on_save` 只有插件加载后才注册，首次保存不会自动格式化。

**解决**：增加 `event = { "BufWritePre" }`，保存前加载 conform，保留 `<leader>F` 手动格式化。

### 10.4 checkhealth 警告清理

**解决**：
- `lazy.lua`：加 `rocks = { enabled = false }`，禁用 luarocks/hererocks 检测
- `options.lua`：加 `vim.g.loaded_node_provider = 0` 等 4 行，禁用不用的外部 provider
- 系统：`sudo pacman -S fd`（Telescope find_files 后备索引工具）

### 10.5 LSP health Unknown filetype

**问题**：`checkhealth vim.lsp` 报 `gotmpl`、`markdown.mdx`、`yaml.docker-compose`、`yaml.gitlab`、`yaml.helm-values` 为 Unknown filetype。

**解决**：新增 `lua/core/filetypes.lua`，用 `vim.filetype.add()` 注册这些 filetype，并在 `core/init.lua` 中于 LSP 加载前 require。

### 10.6 诊断跳转 API 废弃

**问题**：Neovim 0.12 中 `vim.diagnostic.goto_prev()` / `goto_next()` 已废弃。

**解决**：
```lua
vim.diagnostic.jump({ count = -1, float = true })
vim.diagnostic.jump({ count = 1, float = true })
```

### 10.7 conform LSP 格式化优先级

**问题**：`lsp_format = "prefer"` 会让 LSP 抢先于显式配置的 google-java-format/clang-format/stylua。

**解决**：改为 `lsp_format = "fallback"`，显式 formatter 优先，缺工具时 LSP 兜底。

---

## 更新记录

| 日期 | 内容 |
|------|------|
| 2026-06-22 | 添加 9.2：jdtls workspace_dir 跨项目不更新 |
| 2026-06-22 | 添加 10：Telescope/project 懒加载解耦、格式化超时、conform 首次保存、provider/rocks 警告清理 |
| 2026-06-29 | 添加 Mason 初始化顺序、filetype health、诊断跳转废弃 API、bufferline 非强制关闭、format fallback |
| 2026-06-19 | 添加 9：nvim-jdtls root_dir 函数在 Neovim 0.12+ 不生效 |
| 2026-06-05 | 添加 6.4：可视模式 `J`/`K` 映射触发 noice 命令行闪框 |
| 2026-06-04 | 初始创建 |
