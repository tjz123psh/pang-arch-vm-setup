# opencode Global Configuration

这是用户的全局 opencode 配置目录。修改这里会影响所有 opencode 会话；改完需要重启 opencode 才会生效。

## 核心文件

| 文件 | 作用 |
|------|------|
| `opencode.json` | 全局配置，必须符合 `https://opencode.ai/config.json` |
| `instructions.md` | 每次对话都会加载的系统级约定 |
| `build-prompt.md` | 覆盖内置 `build` agent 的提示词 |
| `changelog.md` | 配置事故和踩坑记录 |
| `opencode.example.json` | 示例配置，不一定包含真实凭据 |

## Agents

| Agent | 文件 | 用途 |
|-------|------|------|
| `sisyphus-prometheus` | `agents/sisyphus-prometheus.md` | 默认主力 agent，负责探索、执行、验证 |
| `vision` | `agents/vision.md` | Gemini 视觉分析，处理图片和截图 |
| `build` | `build-prompt.md` + `opencode.json` | 全栈开发 agent |

`opencode.json` 中的 `default_agent` 指向 `sisyphus-prometheus`。`agents/*.md` 会被 opencode 自动发现，`build` 由 `opencode.json` 内联定义。如果临时需要其他 agent，用 opencode 的 agent 切换功能。

## Skills

Skill 目录见 `skills/README.md`。分类如下：

| 分类 | 用途 |
|------|------|
| `meta` | opencode 自身、会话上下文、skill 创建、Bash 脚本生成 |
| `tool` | OCR、网页搜索、网页正文提取 |
| `git` | Git workflow、推送、worktree |
| `nvim` | Neovim 架构、诊断、审计、历史问题 |
| `frontend-design` | 前端 artifact 和文档 dashboard |

## 验证命令

```bash
node -e "JSON.parse(require('fs').readFileSync('/home/pang/.config/opencode/opencode.json','utf8'))"
opencode debug config
opencode debug skill --print-logs --log-level DEBUG
opencode agent list
```

## 维护规则

- 改 opencode 配置前先查 schema 或内置 `customize-opencode` skill。
- 不把大段领域规则塞进 `instructions.md`；放到对应 skill。
- Skill 的 `description` 要写清楚触发场景，避免误加载。
- 新增复杂 skill 时按 `SKILL.md`、`references/`、`scripts/`、`templates/` 拆分。
- 发现配置事故后更新 `changelog.md`。
