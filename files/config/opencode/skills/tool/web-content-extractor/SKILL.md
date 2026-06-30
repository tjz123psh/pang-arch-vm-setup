---
name: web-content-extractor
description: 提取网页正文为干净 Markdown。当用户说"提取网页内容"、"正文提取"、"去广告看文章"、"clean this page"、"阅读模式"、"提取文章"时触发。
---

# Web Content Extractor

通过第三方服务将任意网页的正文（去广告/导航/侧边栏）提取为 Markdown。

## 可用服务

| 服务 | URL 格式 | 优先级 |
|------|----------|--------|
| **Defuddle** | `https://defuddle.md/<目标URL>` | 首选 |
| **Jina AI Reader** | `https://r.jina.ai/<目标URL>` | Defuddle 失败时备用 |

## 执行步骤

1. 从用户请求中提取目标 URL，确保包含协议（缺则补 `https://`）
2. 构造请求 URL：`https://defuddle.md/<目标URL>`
3. 优先用 `webfetch` 读取请求 URL
4. 若 `webfetch` 不可用或返回异常，再用 `bash` 执行 `curl -sL "请求URL"`
5. 若返回空或错误，换 Jina：`https://r.jina.ai/<目标URL>`
6. 返回的 Markdown 直接用于回答，或按用户要求保存到文件

## 注意事项

- 走 `bash`/`curl` 时 URL 始终用双引号包裹，防止 shell 解释特殊字符
- 如果目标 URL 缺少 `http://` 或 `https://`，先补 `https://`
