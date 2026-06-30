---
name: git-workflow
description: Git 版本控制与协作规范，包含 Conventional Commits、分支命名、tag/release 简洁指引。
---

# Git Workflow（个人规范）

## 提交规范（Conventional Commits）

格式：`<type>(<scope>): <description>`

| type | 场景 |
|------|------|
| `feat` | 新功能 |
| `fix` | 修 bug |
| `docs` | 文档 |
| `refactor` | 重构（不改功能） |
| `perf` | 性能优化 |
| `test` | 加测试 |
| `chore` | 构建/工具变动 |

scope 可选（如 `feat(auth): ...`），description 用英文祈使句，首字母小写。

## 分支命名

```
<type>/<short-description>
```

示例：`feat/oauth-login`、`fix/null-pointer`、`refactor/extract-utils`

## 提交粒度

- 一个提交 = 一个逻辑变更，不大不小
- 需要说明 why 时在 body 写，不写废话
- 一天多次提交正常，推之前可以 squash

## Tag / Release

```
git tag -a v<major>.<minor>.<patch> -m "简短说明"
git push origin --tags
```

## PR

本机 solo 开发少用 PR。需要时参考 `references/pull-request.template.md`。

## 参考

- [Conventional Commits](https://www.conventionalcommits.org/)
