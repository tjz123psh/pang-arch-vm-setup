---
name: config-auditing
description: "Neovim configuration audit knowledge base. Use when: reviewing config files for issues, checking deprecated APIs, optimizing settings, or performing health checks. Provides checklists, best practices, and version-specific deprecated API detection patterns."
---

# Neovim 配置审计

系统地分析配置，发现潜在问题、优化空间和废弃 API 使用。

## 文档体系

| 文档 | 用途 | 何时用 |
|------|------|--------|
| [local-checklist.md](local-checklist.md) | **本机**配置专用的审查清单 | 针对本机环境的审计 |
| [general-checklist.md](general-checklist.md) | 通用 Neovim 审查清单 | 系统级配置审查 |
| [best-practices.md](best-practices.md) | lazy.nvim、vim.opt、keymap 最佳实践 | 优化建议 |
| [deprecated-apis.md](deprecated-apis.md) | 按版本分类的废弃 API 检测模式 | 兼容性检查 |

## 快速验证命令

```bash
# Neovim 版本
nvim --version | head -1

# 配置路径
nvim --headless -c "lua print(vim.fn.stdpath('config'))" -c "qa" 2>&1

# Lua 文件数
find ~/.config/nvim -name "*.lua" 2>/dev/null | wc -l

# 插件数（lazy.nvim）
ls ~/.local/share/nvim/lazy 2>/dev/null | wc -l

# 废弃 API 检测
grep -rn "nvim_buf_set_option\|nvim_win_set_option" ~/.config/nvim --include="*.lua" 2>/dev/null | head -10

# 启动时间
nvim --startuptime /tmp/nvim-startup.log +q && tail -5 /tmp/nvim-startup.log

# Lua 语法校验
nvim --headless -c "lua dofile(vim.fn.stdpath('config')..'/init.lua')" -c "qa" 2>&1

# 启动错误检查
nvim --headless -c "qa" 2>&1 | head -20
```

## 评分标准

按问题严重度和数量评级：

| 等级 | 标准 | 说明 |
|------|------|------|
| **A** | 0 Critical, 0-2 Warning | 优秀 |
| **B** | 0 Critical, 3-5 Warning | 良好 |
| **C** | 0 Critical + 6+ Warning 或 1 Critical | 需关注 |
| **D** | 2-3 Critical | 差 |
| **F** | 4+ Critical | 不及格 |

### 严重度定义

| 级别 | 范围 |
|------|------|
| **Critical** | 安全风险、已移除的 API、运行时错误 |
| **Warning** | 性能问题、已废弃但仍在工作的 API、代码风格 |
| **Suggestion** | 可选优化、现代替代方案、组织建议 |

## 审计流程

1. **收集环境信息** — Neovim 版本、插件管理器、配置结构
2. **执行审查** — 先 [local-checklist.md](local-checklist.md) 再 [general-checklist.md](general-checklist.md)
3. **检查版本兼容** — 对照 [deprecated-apis.md](deprecated-apis.md) 标记已废弃/已移除 API
4. **应用最佳实践** — 对照 [best-practices.md](best-practices.md) 提出优化
5. **打分** — 按评分标准给出总体健康度等级

## 审计报告模板

```markdown
## 审计摘要

- **评分**: [A-F]
- **Neovim 版本**: [检测到的版本]
- **配置路径**: [路径]
- **插件数**: [数量]

## 严重问题（Critical）

逐一列出，格式：`文件:行号` — 问题说明 — 修复方案

## 警告（Warning）

逐一列出，格式：`文件:行号` — 问题说明 — 建议

## 建议（Suggestion）

逐一列出可选的优化项

## 统计

| 指标 | 值 |
|------|-----|
| Lua 文件数 | X |
| 总行数 | Y |
| 插件数 | Z |
| 启动时间 | Nms |
| 废弃 API 数 | N |
```
