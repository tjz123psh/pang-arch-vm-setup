---
name: neovim-arch
description: "Use when: 改配置、加插件、加语言支持、查快捷键、查配置架构、查同步规则。提供 Neovim 目录结构、加载顺序、快捷键体系、插件配置模式与文档同步规则。"
---

# Neovim 配置架构

## 使用原则

- 需读文件确认具体值时直接读文件不问用户
- 不熟悉的插件先查官方 README 再动手

## 加载顺序

```
init.lua
  ├── vim.g.mapleader = " "
  ├── vim.g.maplocalleader = "\\"
  ├── require("core")             → core/init.lua
  │     ├── options.lua           → 编辑器全局设置
  │     ├── filetypes.lua         → 自定义 filetype 识别
  │     ├── keymaps.lua           → 全局快捷键
  │     ├── commands.lua          → 自定义命令
  │     └── autocmds.lua         → 自动命令
  ├── require("core.lazy")       → lazy.nvim 启动
  │     └── 自动加载 lua/plugins/ 下所有 *.lua 和 */init.lua
  └── if neovide then require("neovide")
```

## 目录结构

```
~/.config/nvim/
├── init.lua
├── lazy-lock.json
└── lua/
    ├── core/
    │   ├── init.lua       → require options/filetypes/keymaps/commands/autocmds
    │   ├── lazy.lua       → lazy.nvim 插件管理器入口
    │   ├── options.lua    → vim.opt（缩进、搜索、shell、剪贴板）
    │   ├── filetypes.lua  → gotmpl、mdx、docker-compose、gitlab、helm YAML
    │   ├── keymaps.lua    → 全局快捷键
    │   ├── cheatsheet.lua → 快捷键速查浮动窗口数据
    │   ├── commands.lua   → :R :A :LspInfo :LspLog :Projects :JavaInit :JavaRun + Java helper 函数
    │   └── autocmds.lua   → C++/Java 缩进、InsertEnter 清搜索
    ├── neovide.lua        → 透明度、字体、光标动画、IME
    └── plugins/
        ├── theme.lua, treesitter.lua, completion.lua, snippets.lua
        ├── mason.lua, mason-tool-installer.lua, lsp/init.lua, format.lua
        ├── flash.lua, telescope.lua, filetree.lua
        ├── bufferline.lua, statusline.lua, dashboard.lua
        ├── dressing.lua, noice.lua, whichkey.lua
        ├── autopairs.lua, comment.lua
        ├── indentline.lua, neotab.lua, betterescape.lua
        ├── project.lua     → project.nvim + monkey-patch（启动即初始化项目历史）
        ├── terminal.lua    → toggleterm.nvim（浮动/分屏终端）
        ├── dap/init.lua    → nvim-dap + nvim-dap-ui + nvim-dap-virtual-text + 条件/日志断点
        └── lang/
            ├── init.lua    → require cpp + java + go + rust
            ├── cpp.lua     → clangd 扩展 + codelldb 适配器（C/C++ DAP）
            ├── java.lua    → nvim-jdtls + Java DAP
            ├── go.lua      → gopls + delve Go DAP
            └── rust.lua    → rust_analyzer 扩展 + codelldb Rust DAP
```

## 插件配置约定

| 方式 | 适用场景 |
|------|----------|
| `opts = {}` | 简单传参给 setup() |
| `opts = function(_, opts)` | 合并/修改 opts |
| `config = function(_, opts)` | 多步骤 setup、快捷键注册、条件判断 |

| 延迟触发器 | 示例 | 用途 |
|-----------|------|------|
| `event` | `BufReadPost` | treesitter |
| `ft` | `java` | nvim-jdtls |
| `cmd` | `Telescope` | telescope, mason |
| `lazy = false` | — | theme, mason, blink.cmp, lspconfig, project.nvim |
| `keys` | `s` / `S` | flash |

子目录规则：`*/init.lua` 被 lazy 自动加载；同级 `.lua` 需父级 require。

## 快捷键

### 全局（keymaps.lua）

| 按键 | 功能 |
|------|------|
| `<Space>` | Leader（自映射为 `<Nop>`） |
| `jk`（终端模式） | 退出终端模式（替代 `<Esc>`，可能误触） |
| `s` / `S` | flash 跳转/选择（覆盖 `s` 删字符、`S` 删行） |
| `jk`（插入模式） | 退出插入模式（better-escape.vim，无 timeoutlen 依赖） |
| `<C-h/j/k/l>` | 窗口切换 |
| `<leader>sh/sv` | 水平/垂直分割 |
| `<C-s>` | 保存 |
| `<leader>q/wq` | 关闭/保存并关闭窗口 |
| `<leader>bd/fc/hk/e` | 关缓冲区/搜配置/快捷键速查/文件树 |
| `<leader>tt/th/tv` | 切换浮动/水平/垂直终端 |

### 自定义命令（commands.lua）

| 命令 | 功能 |
|------|------|
| `:R` | 重新加载当前 .lua 配置文件 |
| `:A` | 打开欢迎页 |
| `:LspInfo` | 查看 LSP 客户端状态 |
| `:LspLog` | 打开 LSP 日志 |
| `:Projects` | 打开项目列表（Telescope picker） |
| `:JavaInit` | 推导包根目录，生成 pom.xml 作为 jdtls 根标记 + 包目录结构 |
| `:JavaRun` | 运行当前 Java 文件（自动处理有/无 package，javac + java 编译运行） |

### LSP / Telescope / Java / DAP

| 按键 | 功能 | 来源 |
|------|------|------|
| `gd` / `gR` / `K` / `gr` / `gi` | 定义/类型定义/悬停/引用/实现 | LSP |
| `[d` / `]d` | 上/下一个诊断 | LSP |
| `<leader>rn` / `<leader>ca` | 重命名/代码操作 | LSP |
| `<C-k>`（插入模式） | 函数签名提示 | LSP |
| `<leader>ff/fg/fb/fh/fp/fd` | Telescope 搜索 | Telescope |
| `<leader>co` / `<leader>ot` | Java 代码操作/整理 import | Java |
| `<leader>dl` / `<leader>db` / `<leader>dB` / `<leader>dL` / `<leader>dC` / `<F5>` / `<F9>` / `<F10>` / `<F11>` / `<F12>` | DAP 调试 | DAP |
| `gcc` / `gc`（可视） | 注释/取消注释 | comment |

**完整快捷键表**：读 `~/md/nvim/nvim快捷键.md` 或按 `<leader>hk` 看浮动窗口。

### 冲突说明

- `s/S` → flash 接管；原版可 `xi`/`cc` 替代
- `<leader>F` 格式化，`<leader>f` 前缀给 telescope 搜索（fc/fg/fb…），不再冲突
- `H/L` → bufferline 接管为切换缓冲区
- `K` → LSP 缓冲区中为悬停文档
- `gd/gr/gi/gR` → 仅在 LSP 附加的缓冲区中被覆盖

### which-key 要点

- `desc` 优先级：spec 配置 > `vim.keymap.set` 的 desc
- `rhs` 不设则只显示描述不创建键位
- 每个 `vim.keymap.set` 需独立 opts 表（用辅助函数 `desc(d)`），which-key 才能正确读取

## 特殊处理

| 关注点 | 说明 |
|--------|------|
| **Java root_dir 兼容 0.12+** | `vim.lsp.start` 不解析函数式 root_dir，需在 config() 中预求值为字符串再传 opts.root_dir |
| **Java DAP 陷阱** | `mainClass` 必须是字符串（函数不可 JSON 序列化）；java-debug-adapter 必须作为 jdtls bundle 加载；必须先 F9 设断点（不停 main） |
| **C++ DAP 配置** | `cpp.lua` 配了 cpp 3 种、c 2 种；多配置时 F5 弹出 picker |
| **Go DAP 配置** | `go.lua` 配了 delve adapter，自动编译运行当前 package |
| **Rust LSP 扩展** | `rust.lua` 扩展 rust_analyzer 配置（clippy 检查、proc macro 支持） |
| **jdtls 跳过 lspconfig** | `setup = { jdtls = function() return true end }` |
| **ft 懒加载 + 当前 buffer** | `vim.schedule` 检查当前文件类型手动启动 + `FileType` autocmd 兜底后续文件 |
| **project.nvim 项目列表** | `lazy = false` 先初始化项目历史；`:Projects` 用自定义 Telescope picker，同步读历史后展示项目，回车只切 cwd + 刷新 neo-tree，不走 `Telescope projects` 的嵌套 find_files |
| **neo-tree 跟随项目** | `filesystem.bind_to_cwd = true`；project.nvim `set_pwd()` 成功后主动刷新已加载的 neo-tree filesystem state，确保项目列表选中后文件树根目录同步切换 |
| **Mason 初始化顺序** | mason.nvim `lazy = false`；mason-lspconfig config 中先 `require("mason").setup({ PATH = "prepend" })` 再 setup，避免启动时未初始化 |
| **filetype 健康检查** | `core/filetypes.lua` 注册 gotmpl、markdown.mdx、yaml.docker-compose、yaml.gitlab、yaml.helm-values，避免 LSP health Unknown filetype |
| **诊断跳转 API** | `[d`/`]d` 用 `vim.diagnostic.jump({ count = ±1, float = true })`，不用已废弃的 `goto_prev/goto_next` |
| **bufferline 关闭缓冲区** | `close_command = "bdelete %d"`，不使用 `bdelete!`，避免误丢未保存内容 |
| **dap-ui 布局** | 侧栏在右，底部 REPL；断点符号用 Nerd Font（`●◆✕◉→`） |
| **autopairs** | `opts = {}`，不排除任何文件类型 |
| **alpha 条件加载** | 加 `cond = function() return vim.fn.argc() == 0 end`，有文件时不加载，避免闪烁 |
| **输入框 UI 统一** | neo-tree `use_popups_for_input = false` → 委托给 vim.ui.input → dressing 接管 → 与 noice cmdline 风格协调（居中、圆角、60 字符宽） |
| **格式化器统一 4 格缩进** | clang-format（`~/.clang-format`）、google-java-format（`--aosp`）、stylua（默认 4 格）、rustfmt（默认 4 格）全部统一为 4 格缩进 |
| **格式化超时** | `format_on_save.timeout_ms = 2000`（原 500ms 对 Java/C++/Rust 大项目偏短，已调长） |
| **格式化优先级** | `lsp_format = "fallback"`，优先使用显式配置的 stylua/google-java-format/clang-format/rustfmt，缺失时再走 LSP |
| **conform 懒加载** | `event = { "BufWritePre" }`，保存前加载以确保 `format_on_save` 首次保存就生效；`<leader>F` 保留手动格式化 |
| **jdtls workspace_dir 跨项目** | `cmd` 每次 start_or_attach 时重新拼装 `-data` 参数，不同项目用独立 workspace 目录 |

## 如何添加

| 要加什么 | 步骤 |
|----------|------|
| 新插件 | `lua/plugins/<name>.lua` 返回 spec，用 `opts`/`config`/`event`/`cmd`/`ft` |
| 新语言 LSP | 1) mason-lspconfig `ensure_installed` 加服务器；2) lsp/init.lua `opts.servers` 加配置；3) 如需特殊 DAP，建 `lang/<lang>.lua` + `lang/init.lua` 里 require |
| 新语言 DAP | dap/init.lua 或 lang 文件里加 adapter + configuration |
| 新快捷键 | keymaps.lua 加 `map()` + cheatsheet.lua 对应分类 + `~/md/nvim/nvim快捷键.md` 同步 |

## 文档

- `nvim快捷键.md` — 快捷键速查
- `nvim命令.md` / `nvim自定义命令.md` — 命令参考
- `nvim插件介绍.md` — 插件用途

## 文档同步规则（必须遵守）

修改配置时，同步更新三处，缺一不可：

| 改了什么 | 同步到哪里 |
|----------|-----------|
| 快捷键 | 各 `.lua` keymaps → `cheatsheet.lua` → `~/md/nvim/nvim快捷键.md` → 本文件快捷键表 |
| 自定义命令 | `commands.lua` → `~/md/nvim/nvim命令.md` + `nvim自定义命令.md` → 本文件 |
| 插件增删改 | `plugins/*.lua` → `~/md/nvim/nvim插件介绍.md` → 本文件目录树 + 插件列表 |
| 目录/加载顺序 | 相关 `.lua` → `~/md/nvim/nvim配置架构.md` → 本文件 |
| 语言支持 | `lang/*.lua` → `~/md/nvim/nvim配置架构.md` → 本文件 |
| 审计/排障事实 | `skills/nvim/*` → `~/md/nvim/*` → 实际配置文件 |

每轮修改最后一步必须是更新文档。

## 环境

| 项目 | 内容 |
|------|------|
| Neovim | 0.12.3 |
| 插件管理器 | lazy.nvim |
| Leader | 空格 |
| 主题 | catppuccin-mocha |
| 终端 | kitty（JetBrainsMono Nerd Font） |
| 系统 | Arch Linux, Wayland |
| 注释语言 | 中文 |
| 配置总行数 | ~2490 |
| 插件数 | 34 |
