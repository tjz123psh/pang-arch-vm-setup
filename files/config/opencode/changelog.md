## 事故记录

> 踩过的坑记在这里。每条记录写：日期 + 场景 + 修复方式 + 避免再犯的规则。

| 日期 | 场景 | 修复方式 | 避免再犯 |
|------|------|----------|----------|
| 2026-06-22 | opencode skill 从 Skillstore/Claude 模板迁移后，README 底部仍残留推广内容 | 删除 5 个 README 的 Skillstore 尾段，并全局扫描 `Skillstore/skillstore/Claude Code/.claude/skills` | 替换模板文件时检查整文件，不只改开头 |
| 2026-06-22 | `~/.claude/skills` 中旧版 `config-auditing`、`neovim-debugging` 与 opencode 本地 skill 重名，导致 duplicate | 删除两个旧 Claude skill 目录，确认本地 opencode 版被加载 | 审查 skill 时跑 `opencode debug skill --print-logs --log-level DEBUG` |
| 2026-06-22 | opencode skill frontmatter 中保留 `allowed-tools`，官方 schema 不识别 | 删除相关字段，工具名统一写 opencode 小写权限名 | 写 skill 只用 `name/description/license/compatibility/metadata` 等官方字段 |
| 2026-06-29 | 全局 `instructions.md` 过度约束工具使用，和 skill/reference 中的实际命令冲突 | 将全局指令收敛为稳定原则，工具细节下沉到 skill；新增 README/skills 索引 | 全局指令只放跨任务稳定规则，领域流程放 skill |
| 2026-06-29 | `opencode.json` 自定义模型使用旧式 `capabilities.vision` 字段 | 按当前 schema 改为 `attachment` + `modalities`；新增 `default_agent`、`references`、`tool_output`、`compaction` | 改 opencode 配置前先查 `https://opencode.ai/config.json` 或 `opencode debug config` |
| 2026-06-30 | 审计报告发现全局指令仍提到不存在的 `list` 工具，且 `changelog.md` 被当作 instructions 每次加载 | 将工具说明改为 `grep`/`glob`/`read`，补充 `task` 委托说明；`changelog.md` 从 `instructions` 移到 `references.opencode-changelog` | 事故记录放 reference，需要时读取；每次加载的 instructions 只保留可执行规则 |
