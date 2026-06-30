#!/usr/bin/env bash
set -uo pipefail

tmpdir=/tmp/opencode

# ── 1. 确保临时目录 ──
mkdir -p "$tmpdir" || {
  echo "无法创建临时目录 $tmpdir" >&2
  exit 1
}

# ── 2. 剪贴板优先 ──
if wl-paste --list-types 2>/dev/null | grep -q '^image/png$'; then
  wl-paste --type image/png > "$tmpdir/screenshot.png" 2>/dev/null || true
  if [ -s "$tmpdir/screenshot.png" ]; then
    printf '%s\n' "$tmpdir/screenshot.png"
    exit 0
  fi
fi

# ── 3. 截图目录 fallback（两目录全局最新）──
found=$(find "$HOME/Pictures" "$HOME/Pictures/Screenshots" -maxdepth 1 -type f -iname '*.png' -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -n 1 | cut -d' ' -f2-)
if [ -n "$found" ] && [ -s "$found" ]; then
  printf '%s\n' "$found"
  exit 0
fi

# ── 4. 都失败 ──
echo "未找到图片：剪贴板无 image/png，~/Pictures 与 ~/Pictures/Screenshots 下也没有 png" >&2
exit 1
