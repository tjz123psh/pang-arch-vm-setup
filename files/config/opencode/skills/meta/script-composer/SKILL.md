---
name: script-composer
description: "为 ~/scripts/ 编写高质量 Bash 脚本。强制使用模板、参考规则和检查脚本，让弱模型也能产出可运行、可维护的脚本。触发词：写脚本、写个 bash、帮我写个脚本、维护脚本、安装脚本、create a script"
---

# script-composer

目标：即使用能力较弱的模型，也必须靠模板、清单和自动检查写出可运行脚本，而不是自由发挥。

## 必走流程

1. 判断脚本类型：
   - 普通命令脚本：用 `templates/simple.sh`
   - fzf/终端交互脚本：用 `templates/fzf-tool.sh`
   - 系统诊断脚本：用 `templates/diagnostic.sh`
2. 先读参考：
   - `references/bash-style.md`
   - `references/patterns.md`
   - `references/quality-gate.md`
3. 如果要贴近用户现有脚本，优先读实际存在的 `~/scripts/media/b23`、`~/scripts/desktop/check-battery`、`~/scripts/desktop/niri-keys`。
4. 复制最接近的模板，替换脚本名、usage、依赖、参数解析和主逻辑。
5. 写完必须运行：
   - `bash -n <script>`
   - `shellcheck <script>`，如果系统有 shellcheck
   - `~/.config/opencode/skills/meta/script-composer/scripts/check-script.sh <script>`
6. 如果脚本有只读模式或 `--help`，运行它们验证输出。

## 不准跳过

- 不准从空白文件自由写，必须从一个模板开始。
- 不准生成未经 `bash -n` 检查的脚本。
- 不准吞掉依赖缺失；缺依赖用清晰错误和非零退出码。
- 不准写会删除数据、安装包、改系统配置、写 `/etc/` 的脚本，除非用户明确要求。
- 不准为了省事使用 `eval`、反引号、未引用变量或宽泛 `rm -rf`。

## 交付格式

最终回复必须包含：

- 脚本路径
- 使用的模板
- 做了哪些验证
- 如果有未运行的验证，说明原因
