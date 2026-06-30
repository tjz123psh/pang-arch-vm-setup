# web-artifacts-builder

opencode 本地 skill。入口见 `SKILL.md`。

用途：创建复杂的单页前端 artifact，适合需要 React、Tailwind、shadcn/ui、状态管理、路由或打包脚本的任务。简单静态 HTML 不需要加载这个 skill。

## 本地结构

```text
frontend-design/web-artifacts-builder/
├── SKILL.md
├── LICENSE.txt
└── scripts/
    ├── init-artifact.sh
    ├── bundle-artifact.sh
    └── shadcn-components.tar.gz
```

## 检查

修改后运行：

```bash
opencode debug skill --print-logs --log-level DEBUG
```
