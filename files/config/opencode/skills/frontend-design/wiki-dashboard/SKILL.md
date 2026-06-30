---
name: wiki-dashboard
description: Build comprehensive single-file HTML dashboards from wiki/documentation content. Use when: user wants a "dashboard", "参考手册", "文档站点", "全站", "wiki 页面", HTML from docs, or wants to turn documentation/wiki into an interactive single-page HTML reference. Covers content fetching, layout (sidebar + tab-switch), translation (keep tech terms English, prose in target language), and the iterative "not enough content" loop.
---

# Wiki Dashboard Builder

## 工作流程

### 1. 获取内容

用 `webfetch` 拉取原文。遇到 Cloudflare 保护时可以：
- 用 `websearch` 搜镜像/存档
- 用 `textise dot iitty` 先提取纯文本
- 或用 task agent 配合 `webfetch` + `websearch` 多路尝试

### 2. 评估内容量

提取后检查原始文本长度。如果一页只有几百字说明没拉到正文（可能是跳转页或目录页），要拉子页面。

### 3. 内容裁切规则

| 删除 | 保留 |
|---|---|
| 导航栏/页脚/侧边栏 HTML | 正文段落 |
| 目录（Table of Contents） | 命令示例 |
| 编辑历史/版权声明 | Note/Warning/Tip 框 |
| 语言切换链接 | 配置示例 |
| 无关的侧栏文章推荐 | 表格数据 |

### 4. 布局模式

固定模式：左侧导航 + 右侧视图切换，形如：

```
[sidebar]  [topbar 标题/提示]
[  nav  ]  [  content viewport  ]
```

- sidebar 使用 `<button class="nav-item" data-view="id">` 切换
- 视图用 `<div class="view" id="v-id">`，通过 JS 切换 `active` 类
- 顶部显示当前视图标题 + 副标题提示
- 暗色主题为默认，提供亮暗切换

### 5. 内容展开原则（最重要）

用户说"内容太少"时的应对策略：

1. **拉原文**：回到源头 webfetch 完整页面内容，不要从记忆或已有内容中扩写
2. **检查原文是否真有料**：可能你抓的是摘要页而不是详情页
3. **加视图**：扩展覆盖范围比深挖单页更有效——用户觉得"只有这些"时往往是主题不全
4. **每条内容都要实**：每个 `code-section` 或段落至少包含一个完整句子 + 一个实际命令/配置示例，不要只有标签式描述
5. **示例必须可执行**：`pacman -Syu` 这样可直接复制的命令，不要用占位符代替关键参数的伪示例
6. **Note/Warning 要具体**：不要写泛泛的"注意：请小心"，要写原因，如"注意：这可能导致依赖问题，因为 pacman 不支持部分升级"

### 6. 翻译规范

- 技术术语保持英文：`pacman`、`systemd`、`systemctl`、`AUR`、`PKGBUILD`、`makepkg`、`chroot`、`initramfs`、`fstab`、`mkfs`、`GPT`、`UEFI` 等
- 保持命令原文不变：`code` 块内的所有内容保持英文
- 命令描述和解释用中文
- 专有名词（KDE Plasma、GNOME、PipeWire 等）首次出现保留英文，后续可用中文简称
- 翻译要自然，不要机翻腔——读起来像是中文作者写的

### 7. 布局守恒

每加一个视图必须同步三处，遗漏会导致视图不可达：

1. sidebar 加 `<button class="nav-item" data-view="xxx">`
2. HTML 加 `<div class="view" id="v-xxx">`
3. JS titles 对象加 `xxx: ['标题','副标题']`

## 验证清单

- [ ] 所有视图都能通过侧边栏切换到达
- [ ] 深色/浅色主题切换正常
- [ ] 滚动只在视图区域生效（body 无滚动）
- [ ] 每个 `code-section` 和 `card-b` 有实质内容，不是一句空话
- [ ] 内容量是否覆盖了用户提到的所有主题
- [ ] 如有英文内容，技术术语已保留英文、说明已翻译
