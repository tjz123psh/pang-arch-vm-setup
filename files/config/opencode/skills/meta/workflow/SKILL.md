---
name: workflow
description: "Skill 系统总览和路由表。Use when 用户问技能怎么用、技能有哪些、工作流、工作流程、what skills do you have、skill system、用哪个 skill。"
---

# Skill Workflow

本机 skill 按职责分为五类：`meta`、`tool`、`git`、`nvim`、`frontend-design`。只加载当前任务需要的 skill，避免上下文过大。

## 优先级

1. 修改 opencode 自身配置、agent、skill、plugin、MCP：先用内置 `customize-opencode`，再用本地 `skill-creator` 或本文件。
2. 用户明确点名某个 skill：加载被点名的 skill。
3. 任务属于明确领域：按下表加载对应 skill。
4. 无明确领域：不加载 skill，直接按全局 `instructions.md` 工作。

## 路由表

| 场景 | 加载 |
|------|------|
| 恢复会话、了解本机环境、继续上下文 | `session-context` |
| 创建或维护 opencode skill | `skill-creator` |
| 查看 skill 分类和加载规则 | `workflow` |
| 写或维护 Bash 脚本 | `script-composer` |
| 搜网页、查资料、找官方文档 | `web-search` |
| 提取网页正文为 Markdown | `web-content-extractor` |
| OCR 图片/PDF 文字 | `ocr` |
| Git 提交、分支、PR 规范 | `git-workflow` |
| 推送 GitHub、发 Release | `git-push` |
| 隔离开发环境 | `using-git-worktrees` |
| Neovim 架构、插件、语言支持、快捷键同步 | `neovim-arch` |
| Neovim 报错、插件失败、快捷键不生效 | `neovim-debugging` |
| Neovim 健康检查、废弃 API、最佳实践审计 | `config-auditing` |
| Neovim 历史问题复查 | `nvim-troubleshooting` |
| 构建前端 artifact | `web-artifacts-builder` |
| 把 wiki/文档做成 dashboard | `wiki-dashboard` |

## 目录结构

```text
~/.config/opencode/
├── opencode.json              # 全局配置，schema: https://opencode.ai/config.json
├── instructions.md            # 每次对话加载的全局规则
├── changelog.md               # 配置事故记录
├── build-prompt.md            # build agent 提示词
├── agents/
│   ├── sisyphus-prometheus.md # 默认主力 agent
│   └── vision.md              # Gemini 视觉 agent
└── skills/
    ├── meta/                  # opencode 自身、上下文、脚本生成
    ├── tool/                  # OCR / web search / page extraction
    ├── git/                   # git workflow / push / worktree
    ├── nvim/                  # Neovim 架构、诊断、审计、历史问题
    └── frontend-design/       # 前端 artifact 和 dashboard
```

## Neovim 文档同步链

改 Neovim 配置时必须保持同步：

```text
改 ~/.config/nvim/lua/*.lua
  -> 更新 cheatsheet.lua / commands.lua（如涉及快捷键或命令）
  -> 更新 ~/md/nvim/ 对应文档
  -> 更新 neovim-arch/SKILL.md 对应章节
  -> 新问题或新修复记入 nvim-troubleshooting/SKILL.md
```

## 维护规则

- `SKILL.md` 只放路由和核心流程。
- 大量参考资料放 `references/`。
- 可复用、确定性的步骤放 `scripts/`。
- 示例骨架放 `templates/`。
- 修改 skill 后运行 `opencode debug skill --print-logs --log-level DEBUG` 检查是否能加载。
