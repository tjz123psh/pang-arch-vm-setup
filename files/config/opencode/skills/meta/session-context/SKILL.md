---
name: session-context
description: "恢复当前会话关键上下文，快速了解本机工作环境与约定。加载后无需重复问用户环境信息。触发词：环境是什么、context、上下文、刚才说到哪、继续、继续之前的工作、checkpoint、session resume。"
---

# Session Context

> 加载此 skill → 恢复环境上下文，不用重复问用户基础信息。

## 本 skill 做什么

- 告诉 AI 当前用户的工作环境（系统、Neovim、shell、文档体系）
- 列出工作约定（注释风格、回复原则、查文档方式）
- 标记 AI 自身常见问题（注意力涣散、文档遗漏、指令理解偏差）

## 何时加载

| 场景 | 说明 |
|------|------|
| 新对话开始 | 用户说"继续"/"刚才说到哪" |
| 长 session 中间 | 感觉上下文漂移，做 checkpoint 确认 |
| 用户提到环境 | 问"你是用什么系统"之类时直接加载，不用再问 |
| 要改配置前 | 确保知道同步规则 |

## 工作约定

- 注释用**中文**，写"为什么"不写"是什么"
- 回复**简洁**，不加多余解释
- 先查官方文档再回答，不凭空猜测 API
- **意图不清 → 用 question 工具列选项让用户选**；目标明确时直接执行
- 不确定用户想表达什么时，停下来复述自己的理解，让用户确认
- 不因形式化确认拖慢明确任务
- 改配置须按 `nvim/neovim-arch` 的同步规则更新三处文档

## 环境速览

| 类别 | 内容 |
|------|------|
| 系统 | Arch Linux, Wayland (niri) |
| Shell | bash（登录 / Neovim 内部）、fish（kitty 终端） |
| 终端 | kitty, JetBrainsMono Nerd Font, opacity 0.8 |
| Neovim | 0.12.3, lazy.nvim, leader=空格, catppuccin-mocha, ~34 插件 |
| 配置 | `~/.config/nvim/lua/`（~1690 行） |
| 文档 | `~/md/nvim/` + `~/md/linux/`（各自 git 管理） |
| Skill 路径 | `~/.config/opencode/skills/{meta,tool,git,nvim,frontend-design}/` |
| opencode 指令 | `~/.config/opencode/instructions.md`（自动注入每次对话） |
| opencode 配置 | `~/.config/opencode/opencode.json`（默认 agent: `sisyphus-prometheus`） |
| opencode agents | `~/.config/opencode/agents/sisyphus-prometheus.md`、`vision.md` |
| Mason 已装 | clangd, codelldb, jdtls, java-debug-adapter, java-test |
| DM | SDDM + Pixie 主题 |

## 核心文件路径（可直接读）

| 用途 | 路径 |
|------|------|
| Neovim 入口 | `~/.config/nvim/init.lua` |
| 全局快捷键 | `~/.config/nvim/lua/core/keymaps.lua` |
| 快捷键速查数据 | `~/.config/nvim/lua/core/cheatsheet.lua` |
| 自定义命令 | `~/.config/nvim/lua/core/commands.lua` |
| LSP 配置 | `~/.config/nvim/lua/plugins/lsp/init.lua` |
| C++ 语言支持 | `~/.config/nvim/lua/plugins/lang/cpp.lua` |
| Java 语言支持 | `~/.config/nvim/lua/plugins/lang/java.lua` |
| niri 快捷键源 | `~/.config/niri/dms/keybinds.kdl` |
| niri 窗口规则 | `~/.config/niri/config.kdl` |
| 快捷键文档 | `~/md/nvim/nvim快捷键.md` |
| Linux 文档目录 | `~/md/linux/`（仅在用户明确要求时读取具体文档） |
| opencode 配置目录 | `~/.config/opencode/` |
| opencode skill 索引 | `~/.config/opencode/skills/README.md` |

## 常见问题自查

当 AI 出现以下表现时，立即停止并纠正：

| 问题 | 表现 | 处理 |
|------|------|------|
| 注意力涣散 | 忽略用户之前明确说过的约束 | 立即纠正，不狡辩 |
| 文档更新不积极 | 改配置后漏同步三处文档 | 确认三处都改完再继续 |
| 上下文漂移 | >256K token 后中间信息衰减 | 主动做 checkpoint 确认 |
| 指令遵从不稳 | 误解或遗漏用户要求 | 承认并重做 |
