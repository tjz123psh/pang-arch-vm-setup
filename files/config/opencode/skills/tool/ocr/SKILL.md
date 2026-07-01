---
name: ocr
description: >
  Use when: user sends an image or PDF path for text extraction.
  Also for "识别图片" "OCR" "截图文字" "图片文字" "读这个PDF" "提取PDF".
  Triggers: receiving a .pdf, .png, .jpg file path or describing an image/PDF.
  Not for general coding questions.
---

# OCR — 自动图文提取工作流

本机已安装 tesseract + 中文/英文识别数据 + poppler，支持图片和 PDF。

## 核心流程（AI 自动执行）

当用户给出**图片或 PDF 路径**时，AI 按以下步骤自动处理：

```
用户给路径 → 运行包装脚本提取文字 → AI 基于文字内容回答
```

**不用问用户要不要先跑脚本**，直接跑。

## 入口脚本

```bash
~/.config/opencode/skills/tool/ocr/scripts/ocr.sh [图片/PDF路径] [选项]
```

**不传路径**时自动从剪贴板 → `~/Pictures` → `~/Pictures/Screenshots` 取图。

### PDF 常用示例

| 你想做什么 | 命令 |
|-----------|------|
| 读某页内容 | `ocr.sh doc.pdf -f 3 -t 3` |
| 读整个 PDF | `ocr.sh doc.pdf -t 0` |
| PDF 扫描件（强制 OCR） | `ocr.sh doc.pdf -t 0 -O` |

### PDF 支持说明

- 文字页 → `pdftotext` 直接提取（快）
- 扫描/图片页 → tesseract OCR 兜底
- `-O`：跳过 pdftotext，强制所有页 OCR（扫描件专用）
- `-f <n>`：起始页；`-t <n>`：结束页（`-t 0` 为全部）

## 优化参数说明

| 参数 | 值 | 原因 |
|------|-----|------|
| 数据源 | 个人 tessdata 优先，系统 tessdata 回退 | 当前系统可用本地优化数据，新 VM 可直接用 pacman 数据 |
| `--oem 1` | LSTM only | 跳过 legacy 引擎 |
| `--psm 6` | Uniform text block | 适合截图/文档页 |
| `--dpi 300` | 300 DPI | 避免低 DPI 降级 |
| `-l chi_sim+eng` | 中英文混排 | 同时识别 |

## 大 PDF 注意事项

PDF 页数很多时，OCR 输出文本可能很长，超出 AI 上下文窗口。遇到长文本时：
- AI 应提示用户指定页码范围（`-f`/`-t`）
- 或者先 summarize 关键页再回答

## 数据目录

- **优先**：`~/.local/share/tessdata/`
- **回退**：`/usr/share/tessdata/`

## 依赖包

依赖由 `pang-arch-vm-setup` 默认安装：`tesseract`、
`tesseract-data-chi_sim`、`tesseract-data-chi_sim_vert`、
`tesseract-data-eng`、`tesseract-data-osd`、`poppler`、`poppler-glib`。
