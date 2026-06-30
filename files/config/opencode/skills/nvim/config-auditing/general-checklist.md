# 通用审计清单

通用 Neovim 配置审查项，不绑定本机特定配置。

---

## 1. 结构与组织

### 1.1 单一庞大 init.lua

**严重度**: Suggestion
**描述**: 单个 init.lua 超过 200 行应拆分为模块。

```bash
wc -l ~/.config/nvim/init.lua 2>/dev/null | awk '{if($1>200) print "FOUND: "$1" lines"}'
```

### 1.2 lazy-lock.json 在 .gitignore 中

**严重度**: Warning
**描述**: Lock 文件应提交以实现可复现安装。

```bash
grep -q "lazy-lock" ~/.config/nvim/.gitignore 2>/dev/null && echo "FOUND: lazy-lock in .gitignore"
```

### 1.3 硬编码路径

**严重度**: Warning
**描述**: 使用绝对路径而非 stdpath()。

```bash
grep -rn '"/home/\|"/Users/\|"~/' ~/.config/nvim --include="*.lua" 2>/dev/null
```

**修复**: 用 `vim.fn.stdpath('config')`、`vim.fn.stdpath('data')` 等。

### 1.4 混合插件管理器配置

**严重度**: Critical
**描述**: 存在多个插件管理器配置。

```bash
ls ~/.config/nvim/lua/plugins.lua ~/.config/nvim/lua/packer*.lua ~/.config/nvim/plugin/packer*.lua 2>/dev/null
```

---

## 2. 性能

### 2.1 同步插件加载

**严重度**: Warning
**描述**: 插件启动时加载无延迟触发器。

```bash
grep -rn "require\s*(\s*['\"]" ~/.config/nvim/init.lua --include="*.lua" 2>/dev/null | grep -v "lazy\|pcall" | head -10
```

### 2.2 大量启动插件

**严重度**: Warning
**描述**: 启动时加载超过 30 个插件。

```bash
nvim --headless -c "lua local s=require('lazy').stats(); print('Startup plugins:', s.loaded, '/', s.count)" -c "qa" 2>&1
```

### 2.3 BufEnter 上的重操作

**严重度**: Warning
**描述**: 频繁触发的事件上做重操作。

```bash
grep -rn "BufEnter\|BufRead\|BufWinEnter" ~/.config/nvim --include="*.lua" 2>/dev/null | grep -v "\.lazy" | head -10
```

### 2.4 启动时间慢

**严重度**: Warning (>200ms) / Critical (>500ms)

```bash
nvim --startuptime /tmp/startup.log +q && awk '/^[0-9].*--- NVIM/ {print "Total: "$1"ms"}' /tmp/startup.log
```

### 2.5 无保护的 require

**严重度**: Suggestion
**描述**: 不带 pcall 的 require 可能在插件缺失时崩溃。

```bash
grep -rn "^local.*=.*require\s*(" ~/.config/nvim --include="*.lua" 2>/dev/null | grep -v pcall | head -10
```

---

## 3. 安全

### 3.1 暴露凭据

**严重度**: Critical
**描述**: API 密钥、token 或密码在配置文件中。

```bash
grep -rniE "(api_key|apikey|token|password|secret)\s*=\s*['\"][^'\"]+['\"]" ~/.config/nvim --include="*.lua" 2>/dev/null
```

### 3.2 不安全的 Shell 命令

**严重度**: Critical
**描述**: vim.fn.system 中未转义的用户输入。

```bash
grep -rn "vim\.fn\.system.*\.\." ~/.config/nvim --include="*.lua" 2>/dev/null
```

### 3.3 Modeline 未禁用

**严重度**: Warning

```bash
nvim --headless -c "lua print('modeline:', vim.o.modeline)" -c "qa" 2>&1
```

### 3.4 Exrc 未配合 Secure

**严重度**: Critical

```bash
nvim --headless -c "lua print('exrc:', vim.o.exrc, 'secure:', vim.o.secure)" -c "qa" 2>&1
```

---

## 4. 兼容性

### 4.1 废弃 API 使用

**严重度**: Warning（已废弃）/ Critical（已移除）
**描述**: 使用当前 Neovim 版本中废弃或移除的 API。

```bash
# 参考 deprecated-apis.md 按版本检测
grep -rn "nvim_buf_set_option\|nvim_win_set_option\|nvim_set_option" ~/.config/nvim --include="*.lua" 2>/dev/null
```

### 4.2 VimScript 在 Lua 配置中

**严重度**: Suggestion
**描述**: 用 vim.cmd 做有 Lua 等价物的事。

```bash
grep -rn "vim\.cmd.*set\s\|vim\.cmd.*let\s\|vim\.cmd.*autocmd" ~/.config/nvim --include="*.lua" 2>/dev/null | head -10
```

### 4.3 LuaJIT 不兼容

**严重度**: Warning
**描述**: 使用 LuaJIT 不支持的特性（如 goto）。

```bash
grep -rn "goto\s\+\w" ~/.config/nvim --include="*.lua" 2>/dev/null
```

### 4.4 缺少版本检查

**严重度**: Suggestion
**描述**: 使用新 API 时没有版本守卫。

```bash
grep -rn "vim\.lsp\.inlay_hint\|vim\.snippet" ~/.config/nvim --include="*.lua" 2>/dev/null
```

---

## 5. 冗余

### 5.1 重复快捷键

**严重度**: Warning

```bash
grep -rhn "vim\.keymap\.set\|map\s*(" ~/.config/nvim --include="*.lua" 2>/dev/null | \
  sed 's/.*["\x27]\([^"\x27]*\)["\x27].*/\1/' | sort | uniq -d
```

### 5.2 冗余选项设置

**严重度**: Suggestion
**描述**: 设置与默认值相同的选项。

```bash
grep -rn "vim\.o\.compatible\s*=\s*false\|vim\.o\.magic\s*=\s*true" ~/.config/nvim --include="*.lua" 2>/dev/null
```

### 5.3 未使用的插件配置

**严重度**: Suggestion

```bash
grep -roh "require\s*['\"][^'\"]*['\"]" ~/.config/nvim/lua/plugins --include="*.lua" 2>/dev/null | sort -u
# 对比 ~/.local/share/nvim/lazy/
```

### 5.4 同时使用 vim.opt 和 vim.o

**严重度**: Suggestion

```bash
comm -12 \
  <(grep -roh "vim\.opt\.\w*" ~/.config/nvim --include="*.lua" 2>/dev/null | sed 's/vim\.opt\.//' | sort -u) \
  <(grep -roh "vim\.o\.\w*" ~/.config/nvim --include="*.lua" 2>/dev/null | sed 's/vim\.o\.//' | sort -u)
```

---

## 汇总

| 类别 | Critical | Warning | Suggestion |
|------|----------|---------|------------|
| 结构 | 1 | 2 | 1 |
| 性能 | 1 | 4 | 1 |
| 安全 | 3 | 1 | 0 |
| 兼容性 | 1 | 2 | 2 |
| 冗余 | 0 | 1 | 3 |
