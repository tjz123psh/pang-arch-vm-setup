# 本机配置审查清单

与本机当前配置强相关的检查项。每次审计优先执行。

## 1. Neovim 版本兼容

### 1.1 vim.lsp.start root_dir 函数签名（0.12+）

**严重度**: Critical
**描述**: 0.12+ 要求 `root_dir` 签名为 `function(bufnr, on_dir)`，旧签名 `function(fname)` 不生效。

```bash
# 检测：查找函数式 root_dir
grep -rn "root_dir\s*=\s*function\s*(" ~/.config/nvim/lua --include="*.lua" 2>/dev/null | grep -v "on_dir"
```

**本机受影响文件**: `lua/plugins/lang/java.lua`（已在 config() 中预求值）、`lua/plugins/lang/cpp.lua`（已用新签名）。

---

### 1.2 jdtls 跳过 lspconfig

**严重度**: Suggestion
**描述**: jdtls 不由 lspconfig 管理，`lsp/init.lua` 中 `setup.jdtls` 返回 `true` 跳过。

```bash
# 确认跳过逻辑还在
grep -rn "jdtls.*return true" ~/.config/nvim/lua --include="*.lua" 2>/dev/null
```

---

### 1.3 Mason 不自动启用 LSP

**严重度**: Suggestion
**描述**: `automatic_enable = false`，Mason 只安装，不管理启动。

```bash
grep -rn "automatic_enable" ~/.config/nvim/lua --include="*.lua" 2>/dev/null
```

### 1.4 Mason 必须先于 mason-lspconfig setup

**严重度**: Warning
**描述**: 启动时不应出现 `mason.nvim has not been set up`。`lsp/init.lua` 中 mason-lspconfig 的 config 要先 `require("mason").setup({ PATH = "prepend" })`。

```bash
grep -rn "mason.*setup.*PATH\\|mason-lspconfig.*setup" ~/.config/nvim/lua/plugins/lsp/init.lua 2>/dev/null
nvim --headless '+qa' 2>&1 | grep -i "mason.nvim has not been set up"
```

### 1.5 诊断跳转不用废弃 API

**严重度**: Warning
**描述**: Neovim 0.12 中 `vim.diagnostic.goto_prev/goto_next` 已废弃，使用 `vim.diagnostic.jump({ count = ±1, float = true })`。

```bash
grep -rn "diagnostic\\.goto_prev\\|diagnostic\\.goto_next" ~/.config/nvim/lua --include="*.lua" 2>/dev/null
grep -rn "diagnostic\\.jump" ~/.config/nvim/lua/plugins/lsp/init.lua 2>/dev/null
```

---

## 2. 懒加载与性能

### 2.1 Telescope + project.nvim 解耦

**严重度**: Warning
**描述**: project.nvim 启动即初始化项目历史，但不能在 `project.lua` 中 require telescope；Telescope 扩展注册必须在 `telescope.lua` 的 config 中。

```bash
# project.lua 不应引用 telescope
grep -rn "telescope" ~/.config/nvim/lua/plugins/project.lua 2>/dev/null
grep -rn "lazy = false" ~/.config/nvim/lua/plugins/project.lua 2>/dev/null
```

### 2.1.1 项目列表首开可用

**严重度**: Warning
**描述**: 启动页项目列表和 `<leader>fp` 必须走 `:Projects`，该命令同步读取 project.nvim 历史并使用自定义 Telescope picker。不要直接调用 `Telescope projects`，避免默认嵌套 find_files 在返回 alpha 后二次选择卡住。

```bash
grep -rn "Projects" ~/.config/nvim/lua/core/commands.lua ~/.config/nvim/lua/plugins/dashboard.lua ~/.config/nvim/lua/plugins/telescope.lua 2>/dev/null
grep -rn "<cmd>Telescope projects" ~/.config/nvim/lua 2>/dev/null
```

### 2.1.2 neo-tree 跟随项目 cwd

**严重度**: Warning
**描述**: 从项目列表选中项目会更新 cwd，neo-tree 必须绑定 cwd；project.nvim `set_pwd()` 成功后也应主动刷新已加载的 neo-tree filesystem state。

```bash
grep -rn "bind_to_cwd.*true" ~/.config/nvim/lua/plugins/filetree.lua 2>/dev/null
grep -rn "original_set_pwd\\|manager.navigate" ~/.config/nvim/lua/plugins/project.lua 2>/dev/null
```

### 2.2 conform 懒加载同时含 event 和 keys

**严重度**: Warning
**描述**: `format.lua` 必须有 `event = { "BufWritePre" }` 确保首次保存格式化，同时保留 `keys = { "<leader>F" }`。

```bash
grep -rn "event.*BufWritePre\|keys.*leader.F" ~/.config/nvim/lua/plugins/format.lua 2>/dev/null
```

### 2.3 格式化超时

**严重度**: Suggestion
**描述**: `timeout_ms` 应为 2000（大项目 500ms 偏短）。

```bash
grep -rn "timeout_ms" ~/.config/nvim/lua --include="*.lua" 2>/dev/null
```

### 2.4 格式化器优先级

**严重度**: Warning
**描述**: `conform.nvim` 应使用 `lsp_format = "fallback"`，优先走显式配置的 stylua/google-java-format/clang-format/rustfmt，缺工具时再用 LSP。

```bash
grep -rn "lsp_format.*fallback" ~/.config/nvim/lua/plugins/format.lua 2>/dev/null
```

### 2.5 alpha 条件加载

**严重度**: Suggestion
**描述**: dashboard 用 `cond = function() return vim.fn.argc() == 0 end` 避免有文件时闪烁。

```bash
grep -rn "cond\|argc" ~/.config/nvim/lua/plugins/dashboard.lua 2>/dev/null
```

---

## 3. 快捷键

### 3.1 which-key 含 localleader 触发器

**严重度**: Warning
**描述**: `triggers` 中要包含 `\\` 对 localleader 的自动展开。

```bash
grep -A5 "triggers" ~/.config/nvim/lua/plugins/whichkey.lua 2>/dev/null
```

### 3.2 s/S 被 flash 覆盖

**严重度**: Suggestion
**描述**: 确认 keymaps.lua 不用 `s`/`S` 做其他用途。

### 3.3 可视模式 J/K 不走命令行

**严重度**: Suggestion
**描述**: 用 Lua 函数 + `vim.cmd` 直调，避免 noice 拦截。

```bash
grep -A3 "map.*x.*\"J\"\|map.*x.*\"K\"" ~/.config/nvim/lua/core/keymaps.lua 2>/dev/null
```

---

## 4. 文档同步

### 4.1 修改快捷键后更新 cheatsheet 和快捷键 md

**严重度**: Warning
**描述**: 按 `neovim-arch` 规则，改快捷键须同步三处：`.lua` → `cheatsheet.lua` → `nvim快捷键.md` → `neovim-arch`。

### 4.2 修改插件后更新文档

**严重度**: Warning
**描述**: 插件增删改须同步 `nvim插件介绍.md` 和 `neovim-arch` 目录树。

### 4.3 修改核心模块后更新架构文档

**严重度**: Warning
**描述**: 新增 `core/filetypes.lua` 这类核心模块时，同步 `neovim-arch`、`local-patterns.md`、`nvim配置架构.md`。

---

## 5. 已解决模式

### 5.1 project.nvim monkey-patch 未丢失

**严重度**: Warning
**描述**: `project.lua` 中运行时补丁 `find_lsp_root` 使用 `vim.lsp.get_clients()` 替代旧 API。

```bash
grep -rn "get_clients\|find_lsp_root" ~/.config/nvim/lua/plugins/project.lua 2>/dev/null
```

### 5.2 没有 blink.cmp 双空格映射

**严重度**: Suggestion
**描述**: `["<Space><Space>"]` 映射已删除。

```bash
grep -rn "Space.*Space" ~/.config/nvim/lua --include="*.lua" 2>/dev/null
```

### 5.3 shell 为 bash 而非 fish

**严重度**: Suggestion
**描述**: `vim.o.shell` 应通过 `vim.fn.exepath("bash")` 解析到 bash，找不到时保留默认 shell，确保 lazy.nvim build 不因 fish 语法报错。

```bash
grep -rn "vim.o.shell" ~/.config/nvim/lua --include="*.lua" 2>/dev/null
```

### 5.4 checkhealth 警告已清理

**严重度**: Suggestion
**描述**: 确认 `options.lua` 有 `loaded_node_provider = 0` 等 4 行，`lazy.lua` 有 `rocks = { enabled = false }`。

```bash
grep -rn "loaded_node_provider\|loaded_perl_provider\|loaded_ruby_provider\|loaded_python" ~/.config/nvim/lua --include="*.lua" 2>/dev/null
grep -rn "rocks.*enabled.*false" ~/.config/nvim/lua/core/lazy.lua 2>/dev/null
```

### 5.4.1 Mason health 可选工具警告

**严重度**: Suggestion
**描述**: `checkhealth mason` 中 wget、luarocks、Ruby、Composer、PHP、Julia、pip 缺失通常只是 Mason 的可选生态探测，不代表本配置故障。优先确认当前配置实际依赖的工具链和 Mason 包可用。

```bash
nvim --headless '+checkhealth mason' '+qa'
nvim --headless '+checkhealth vim.lsp' '+qa'
```

**判定**: `vim.lsp` 无 Unknown filetype、`mason.nvim` registry 正常、curl/git/unzip/tar/bash 可用，且已配置语言的 LSP/DAP/formatter 已安装即可通过。不要为清可选 Warning 修改核心配置。

### 5.5 LSP Unknown filetype 已清理

**严重度**: Warning
**描述**: `core/filetypes.lua` 应注册 gotmpl、markdown.mdx、yaml.docker-compose、yaml.gitlab、yaml.helm-values，`checkhealth vim.lsp` 不应再出现 Unknown filetype。

```bash
grep -rn "gotmpl\\|markdown.mdx\\|yaml.docker-compose\\|yaml.gitlab\\|yaml.helm-values" ~/.config/nvim/lua/core/filetypes.lua 2>/dev/null
nvim --headless '+checkhealth vim.lsp' '+qa' 2>&1 | grep "Unknown filetype"
```

### 5.6 bufferline 不强制丢未保存修改

**严重度**: Warning
**描述**: bufferline 的关闭命令应为 `bdelete %d`，不能是 `bdelete! %d`。

```bash
grep -rn "bdelete!" ~/.config/nvim/lua/plugins/bufferline.lua 2>/dev/null
```
