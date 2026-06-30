---
name: neovim-debugging
description: "Debug Neovim configuration issues. Use when: user reports Neovim errors, keymaps not working, plugins failing, lazy.nvim loading problems, LSP/DAP issues, or config problems. Provides systematic diagnosis through hypothesis testing."
---

# Neovim Debugging

## 使用原则

1. **先自己查** — 用 headless 模式或文件检查，不急着问用户
2. **形成假设 → 测最可能的一个 → 缩小范围 → 确认根因**
3. **跑不动再问** — 只有需要交互反馈时才问

## 问题分类与诊断路径

| 问题类型 | 起点 |
|----------|------|
| **Lua 错误** (`E5108`) | [error-patterns.md](error-patterns.md) → 解码错误消息 |
| **按键无效** | [diagnostic-flowchart.md](diagnostic-flowchart.md) → 映射诊断 |
| **插件未加载** | [local-patterns.md](local-patterns.md) → 查本机配置 + 已踩坑 |
| **性能问题** | [diagnostic-flowchart.md](diagnostic-flowchart.md) → 性能诊断 |
| **UI/视觉** | [diagnostic-flowchart.md](diagnostic-flowchart.md) → UI 诊断 |

## 快速命令

```bash
nvim --headless -c "lua print(pcall(require, 'PLUGIN'))" -c "qa" 2>&1    # 检查插件
nvim --headless -c "lua print(vim.inspect(require('lazy').stats()))" -c "qa" 2>&1  # lazy 状态
nvim --headless -c "lua print('leader:', vim.g.mapleader)" -c "qa" 2>&1           # leader
```

## 决策框架

```
1. 能复现/验证吗？       → YES: headless 或读文件 | NO: 问用户具体信息
2. 间歇还是稳定？        → 稳定: 静态分析 | 间歇: 运行时状态/时序
3. 以前正常吗？          → 正常: 查最近变更 | 不正常: 查基础安装/依赖
4. 局部还是全局？        → 局部: 具体插件配置 | 全局: 核心配置/leader
```

## 参考文档

| 文档 | 用途 |
|------|------|
| [local-patterns.md](local-patterns.md) | **本机**目录结构、已踩坑问题、检查清单 |
| [general-reference.md](general-reference.md) | 通用插件排查、信息收集方法、反模式 |
| [error-patterns.md](error-patterns.md) | 错误信息到原因的索引 |
| [diagnostic-flowchart.md](diagnostic-flowchart.md) | 按问题类型的分步诊断流程 |
