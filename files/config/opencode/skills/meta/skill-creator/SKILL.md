---
name: skill-creator
description: 创建和维护 opencode skill 的指南。当用户说"写个 skill"、"创建技能"、"加个 skill"、"写 skills"、"维护 skill"时触发。
---

# Skill Creator

指导如何写出符合 opencode 官方规范的 skill（基于 https://opencode.ai/en/docs/skills）。

## 核心规则

1. frontmatter 精确——`name` 和 `description` 是 AI 路由的唯一依据
2. body 简短直接——写"做什么"和"怎么做"，不写背景介绍
3. 复杂参考放 `references/` 目录，不塞进 `SKILL.md`
4. 重复性步骤写成 `scripts/` 脚本，不要每次手写
5. 示例路径用 `~/.config/opencode/` 体系

## Skill 结构

```
<category>/<skill-name>/
├── SKILL.md            # 必填，文件名必须全大写
├── scripts/            # 可选，可复用的 shell/python 脚本
└── references/         # 可选，参考文档/模板/清单
```

分类目录：`nvim/` `git/` `meta/` `tool/`，放在 `~/.config/opencode/skills/` 下。

## Frontmatter 规范

```yaml
---
name: my-skill
description: 一句话说明功能 + 触发词列表。当用户说"xxx"、"yyy"时触发。
---
```

| 字段 | 必填 | 说明 |
|------|------|------|
| `name` | 是 | skill 唯一标识，1-64 字符，必须与目录名完全一致 |
| `description` | 是 | 功能与触发场景，1-1024 字符 |
| `license` | 否 | 许可证，如 `MIT`、`Apache-2.0` |
| `compatibility` | 否 | 兼容性说明，如 `opencode`，最长 500 字符 |
| `metadata` | 否 | 自定义键值对（string→string） |

### 命名规则

正则：`^[a-z0-9]+(-[a-z0-9]+)*$`

- 仅小写字母 + 数字，单词间单连字符分隔
- 1-64 字符
- 不以 `-` 开头或结尾
- 不含连续 `--`
- 必须与所在**目录名完全一致**

合法：`git-release`、`web-content-extractor`、`deploy2prod`
非法：`Git-Release`（大写）、`-release`（开头连字符）、`git--release`（双连字符）

## Body 写作指南

- 用**指令式**，直接告诉 AI 怎么做
- 步骤编号或列表，清晰可执行
- 引用具体 opencode 工具名：`bash`、`webfetch`、`grep`、`read` 等
- 遇到分支情况给 fallback 规则
- 不写模型已经知道的常识，不写 marketing 话术

反面示例：
```
这是一个非常有用的技能，可以帮助你更好地完成工作。
```

正面示例：
```
1. 用 `webfetch` 读取 `https://defuddle.md/<URL>`
2. 若返回空，换 `https://r.jina.ai/<URL>`
```

## 资源文件选择

| 放 `scripts/` | 放 `references/` |
|---|---|
| 流程脆弱/步骤多 | schema、API 文档、策略文本 |
| 同一段代码反复写 | 只有部分内容被用到 |
| 确定性输出 | 供查阅的参考资料 |

## 创建流程

1. 确认用户需求——什么场景触发？做什么？
2. 确定 skill name，创建 `<category>/<name>/` 目录
3. 写 frontmatter：`name` + `description`（含触发词），可选加 `license`、`compatibility`、`metadata`
4. 写 body：步骤清晰，分支处理明确
5. 需要的话加 `scripts/` 或 `references/`
6. 复核：删掉所有废话、模型已知内容、不相关背景

## 编辑已有 Skill

- 不改变原有触发意图，除非用户明确要求
- description 触发词太宽/太窄时收紧
- body 太长时把细节移入 `references/`
