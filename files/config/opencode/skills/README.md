# Skills Index

本目录保存全局 opencode skills。每个 skill 必须放在独立目录，并包含 `SKILL.md`。

## 分类

### meta

| Skill | 用途 |
|-------|------|
| `workflow` | skill 路由表和目录说明 |
| `session-context` | 恢复本机环境和长期上下文 |
| `skill-creator` | 创建和维护 opencode skill |
| `script-composer` | 用模板、参考和检查脚本生成高质量 Bash 脚本 |

### tool

| Skill | 用途 |
|-------|------|
| `ocr` | 图片/PDF OCR |
| `web-search` | 多策略网页搜索 |
| `web-content-extractor` | 提取网页正文为 Markdown |

### git

| Skill | 用途 |
|-------|------|
| `git-workflow` | 提交、分支、PR 规范 |
| `git-push` | 推送 GitHub 和发 Release |
| `using-git-worktrees` | 创建隔离 worktree |

### nvim

| Skill | 用途 |
|-------|------|
| `neovim-arch` | 本机 Neovim 架构和同步规则 |
| `neovim-debugging` | Neovim 报错和插件问题诊断 |
| `config-auditing` | Neovim 配置审计 |
| `nvim-troubleshooting` | 历史问题库 |

### frontend-design

| Skill | 用途 |
|-------|------|
| `web-artifacts-builder` | 构建前端 artifact |
| `wiki-dashboard` | 将文档/wiki 做成 dashboard |

## 编写规则

- `SKILL.md`：只写触发条件、核心流程和必须遵守的规则。
- `references/`：放长参考、清单、schema、策略文档。
- `scripts/`：放可重复运行的检查、转换、生成脚本。
- `templates/`：放弱模型可复制的起始模板。

## 检查

```bash
opencode debug skill --print-logs --log-level DEBUG
```

如果新增或重命名 skill，确认：

- frontmatter 有 `name` 和 `description`
- `name` 与目录名一致
- `description` 说明“何时使用”，不只说明“它是什么”
- 没有 Claude/Skillstore 残留字段，如 `allowed-tools`
