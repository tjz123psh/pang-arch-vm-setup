# 本机调试模式

本机 Neovim 配置的事实与已解决问题，供调试时快速参考。

## 环境

| 项目 | 内容 |
|------|------|
| Neovim | 0.12.3 |
| 插件管理器 | lazy.nvim |
| Leader/Localleader | 空格 / `\` |
| 主题 | catppuccin-mocha |
| 终端 | kitty (Wayland), JetBrainsMono Nerd Font |
| 系统 | Arch Linux |
| 配置路径 | `~/.config/nvim/` |

## 目录结构

```
~/.config/nvim/
├── init.lua
├── lazy.lua
├── lazy-lock.json
└── lua/
    ├── core/
    │   ├── init.lua         → require options/filetypes/keymaps/commands/autocmds
    │   ├── options.lua
    │   ├── filetypes.lua    → gotmpl、mdx、docker-compose/gitlab/helm YAML
    │   ├── keymaps.lua
    │   ├── cheatsheet.lua
    │   ├── commands.lua
    │   └── autocmds.lua
    ├── neovide.lua
    └── plugins/
        ├── theme.lua, treesitter.lua, completion.lua, snippets.lua
        ├── mason.lua, mason-tool-installer.lua, lsp/init.lua, format.lua
        ├── flash.lua, telescope.lua, filetree.lua
        ├── bufferline.lua, statusline.lua, dashboard.lua
        ├── dressing.lua, noice.lua, whichkey.lua
        ├── autopairs.lua, comment.lua
        ├── indentline.lua, neotab.lua, betterescape.lua
        ├── project.lua          → lazy = false（启动即初始化项目历史）
        ├── terminal.lua
        ├── dap/init.lua
        └── lang/
            ├── init.lua         → require cpp + java + go + rust
            ├── cpp.lua, java.lua, go.lua, rust.lua
```

## 加载顺序

1. `init.lua` → 设 `mapleader` / `maplocalleader`
2. `require("core")` → options → keymaps → commands → autocmds
3. `require("core.lazy")` → lazy.nvim 加载 `lua/plugins/` 下所有 spec
4. `require("neovide")`（仅 Neovide 时）

## 已踩坑问题

### jdtls root_dir（Neovim 0.12+）

`vim.lsp.start` 不解析函数式 `root_dir`，必须在 `config()` 中预求值为字符串再传入。详见 `nvim-troubleshooting` §9.1。

### jdtls workspace_dir 跨项目

`cmd` 每次 `start_or_attach` 时重新拼装 `-data` 参数，不同项目用独立 workspace 目录。详见 `nvim-troubleshooting` §9.2。

### project.nvim + Telescope 项目列表

project.lua 用 `lazy = false`，启动即初始化项目历史；Telescope 扩展注册仍放在 `telescope.lua` 的 config 中，避免 project.lua 直接 require telescope。项目列表入口统一走 `:Projects`：先加载 project/telescope/neo-tree，再同步读取 project.nvim 历史，用自定义 picker 展示项目；回车只切 cwd 并打开/刷新 neo-tree，不走 `Telescope projects` 的默认嵌套 find_files。详见 `nvim-troubleshooting` §10.1。

### neo-tree 跟随项目切换

`filetree.lua` 使用 `filesystem.bind_to_cwd = true`。项目列表选中项目后，project.nvim 会设置 cwd；本机还包装了 `Project.set_pwd()`，成功切换后主动调用已加载的 neo-tree filesystem state 刷新到项目目录，不应继续停在 `$HOME`。

### conform 首次保存加载

`event = { "BufWritePre" }` 确保 `format_on_save` 在首次保存前生效。保留 `<leader>F` 手动格式化。详见 `nvim-troubleshooting` §10.3。

### 可视模式 J/K 与 noice

用 Lua 函数 + `vim.cmd` 直调，不走命令行模式，noice 不拦截闪框。详见 `nvim-troubleshooting` §6.4。

### Mason 初始化顺序 + 不管理 LSP 启动

`mason.nvim` 为 `lazy = false`，`mason-lspconfig` config 里先 `require("mason").setup({ PATH = "prepend" })` 再 setup，避免启动提示 mason 未初始化。`automatic_enable = false`，Mason 只负责安装；全靠 `vim.lsp.config` + `vim.lsp.enable` 或 nvim-jdtls 手动启动。详见 `nvim-troubleshooting` §1.2–§1.3。

### 自定义 filetype 识别

`core/filetypes.lua` 注册 `gotmpl`、`markdown.mdx`、`yaml.docker-compose`、`yaml.gitlab`、`yaml.helm-values`。LSP health 不应再出现这些 Unknown filetype 警告。

### jdtls 跳过 lspconfig

`setup = { jdtls = function() return true end }`，避免双重启动。详见 `nvim-troubleshooting` §1.4。

### Java DAP 注意事项

- `mainClass` 必须是字符串（函数不可 JSON 序列化）
- java-debug-adapter 必须作为 jdtls bundle 加载
- 必须先 F9 设断点（不停 main）
- 快捷键重复注册问题：用 `setup_java_keys(bufnr)` 函数复用
详见 `nvim-troubleshooting` §5.1–§5.4。

### C++ DAP

cpp.lua 配置了 cpp 3 种、c 2 种运行配置；多配置时 F5 弹出 picker。

### blink.cmp 双空格映射

`["<Space><Space>"]` 导致空格延迟，已删，改打字时自动触发。

### timeoutlen 与 jk 冲突

已换用 `better-escape.vim` 插件（不依赖 timeoutlen），删掉 `keymaps.lua` 中的 `inoremap jk <Esc>`。

### 格式化统一

全部统一 4 格缩进：clang-format（`~/.clang-format`）、google-java-format（`--aosp`）、stylua、rustfmt。`format_on_save.timeout_ms = 2000`，`lsp_format = "fallback"`，显式格式化器优先，LSP 兜底。

### bufferline 不强制关闭未保存 buffer

`bufferline.lua` 使用 `bdelete %d`，不是 `bdelete! %d`。关闭有未保存修改的 buffer 会失败并提示，而不是直接丢内容。

### which-key 关键设置

- `triggers` 配置了 `\\` 触发 localleader 自动展开
- `desc` 优先级：spec 配置 > `vim.keymap.set` 的 desc
- 每个 keymap 需独立 opts 表（用辅助函数 `desc(d)`）
- 配置在 `lua/plugins/whichkey.lua`

### project.nvim 使用已废弃 API

`patch`：运行时 monkey-patch `find_lsp_root`，用 `vim.lsp.get_clients()` 替代。不修改插件源文件。

### 快捷键冲突

- `s/S` 被 flash 接管，原功能可用 `xi`/`cc` 替代
- `K` 在 LSP 缓冲区中为悬停文档
- `H/L` 被 bufferline 接管为切换缓冲区
- `<leader>F` 格式化 vs `<leader>f` 前缀给 telescope 搜索

## 调试检查清单

当面对一个问题时：

1. 读 `nvim-arch` → 了解本机结构和插件加载规则
2. 查 `nvim-troubleshooting` → 是否已有踩坑记录
3. 查本文件 → 针对性的本机事实
4. 查 `general-reference.md` → 通用插件排查
5. 查 `error-patterns.md` → 错误匹配

## 相关文档

| 文档 | 用途 |
|------|------|
| `nvim-arch` / `SKILL.md` | 目录结构、加载顺序、快捷键体系 |
| `nvim-troubleshooting` / `SKILL.md` | 已解决问题与解决方案 |
| `neovim-debugging` / `local-patterns.md` | 本文件：本机调试事实 |
| `neovim-debugging` / `error-patterns.md` | 错误信息索引 |
