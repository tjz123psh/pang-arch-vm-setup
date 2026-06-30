#!/usr/bin/env bash
#
# OCR 优化包装脚本
# - 数据源：tessdata_best（纯 LSTM 浮点模型）
# - 引擎：--oem 1（跳过 legacy 引擎）
# - 分段：--psm 6（均匀文本块，适合截图）
# - PDF 混合模式：文字页 pdftotext（快），空白/图片页 OCR 兜底
#
# 用法: ocr.sh [选项] [图片/PDF路径]
#   不传路径时自动从剪贴板或 ~/Pictures 取图
#
# 选项:
#   -l <lang>   语言，默认 chi_sim+eng
#   --psm <n>   页面分段模式，默认 6
#   --dpi <n>   指定 DPI，默认 300
#   -f <n>      PDF 起始页，默认 1
#   -t <n>      PDF 结束页，默认只处理第 1 页；-t 0 表示全部
#   -O          强制 OCR 模式（所有页走 OCR，不做 pdftotext）

set -uo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
TESSDATA="$HOME/.local/share/tessdata"
LANG="chi_sim+eng"
PSM=6
DPI=300
INPUT=""
PDF_FIRST=1
PDF_LAST=""
FORCE_OCR=false

# ── 解析参数 ──
while [[ $# -gt 0 ]]; do
  case "$1" in
    -l) LANG="$2"; shift 2 ;;
    --psm) PSM="$2"; shift 2 ;;
    --dpi) DPI="$2"; shift 2 ;;
    -f) PDF_FIRST="$2"; shift 2 ;;
    -t) PDF_LAST="$2"; shift 2 ;;
    -O) FORCE_OCR=true; shift ;;
    -h|--help)
      sed -n '2,21p' "$0"
      exit 0
      ;;
    --) shift; INPUT="$*"; break ;;
    -*)
      echo "未知选项: $1" >&2
      exit 1
      ;;
    *)
      INPUT="$1"
      shift
      ;;
  esac
done

# ── 获取输入文件 ──
if [[ -z "$INPUT" ]]; then
  INPUT="$("$SELF_DIR/get-image.sh")" || {
    echo "无法获取图片。提供路径: ocr.sh /path/to/image.png" >&2
    exit 1
  }
fi

if [[ ! -f "$INPUT" ]]; then
  echo "文件不存在: $INPUT" >&2
  exit 1
fi

# ── 判断是否 PDF ──
is_pdf=false
case "${INPUT,,}" in
  *.pdf) is_pdf=true ;;
esac
if ! $is_pdf; then
  mime="$(file --mime-type -b "$INPUT" 2>/dev/null)"
  [[ "$mime" == "application/pdf" ]] && is_pdf=true
fi

###############################################################################
#  PDF 处理（混合模式）
###############################################################################
if $is_pdf; then
  # 页面范围
  if [[ -z "$PDF_LAST" ]]; then
    PDF_LAST=$PDF_FIRST          # 未指定 → 只处理起始页
  elif [[ "$PDF_LAST" == "0" ]]; then
    PDF_LAST=""                  # -t 0 → 全部页
  fi

  tmpdir="$(mktemp -d /tmp/ocr-pdf-XXXXXX)"
  trap 'rm -rf "$tmpdir"' EXIT

  # 先拆页
  pdftoppm -png -r "$DPI" -f "$PDF_FIRST" ${PDF_LAST:+-l "$PDF_LAST"} "$INPUT" "$tmpdir/page" 2>/dev/null || {
    echo "PDF 转图片失败，是否安装了 poppler？" >&2
    exit 1
  }

  for page_img in "$tmpdir"/page-*.png; do
    [[ -f "$page_img" ]] || continue
    page_num="$(basename "$page_img" .png | sed 's/page-//')"

    # 上一页输出加空行
    [[ -n "${page_done:-}" ]] && echo ""
    page_done=true

    # 混合模式：先 pdftotext（图片页几乎无返回值 → 兜底 OCR）
    text=""
    if ! $FORCE_OCR; then
      text="$(pdftotext -f "$page_num" -l "$page_num" "$INPUT" - 2>/dev/null || true)"
    fi

    # pdftotext 返回有效文字（去空白后 ≥10 字符）→ 直接输出
    # shellcheck disable=SC2001  # sed 比 bash 变量替换更简洁
    stripped="$(echo "$text" | sed 's/[[:space:]]//g')"
    echo "--- Page $page_num ---"
    if [[ -n "$text" && ${#stripped} -ge 10 ]]; then
      # pdftotext 输出含 `\f`（换页符）及 ANSI 转义等控制字符，清掉再给 AI
      # 顺序：先 sed 清 ANSI 序列，再 tr 清剩余控制符（\e 在 ANSI 序列中已被 sed 处理完）
      printf '%s\n' "$text" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | tr -d '\f\r\b\a'
    else
      # 回退到 OCR
      echo "(OCR)"
      TESSDATA_PREFIX="$TESSDATA" \
        tesseract "$page_img" stdout \
          -l "$LANG" --oem 1 --psm "$PSM" --dpi "$DPI" \
          2>/dev/null
    fi
  done

  echo "--- END ---"
  exit 0
fi

###############################################################################
#  图片 OCR
###############################################################################
TESSDATA_PREFIX="$TESSDATA" \
  tesseract "$INPUT" stdout \
    -l "$LANG" --oem 1 --psm "$PSM" --dpi "$DPI" \
    2>/dev/null
