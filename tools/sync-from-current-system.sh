#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_MANIFEST="$ROOT_DIR/config/dotfiles-manifest.txt"

DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: tools/sync-from-current-system.sh [options]

Copies a curated, secret-free subset of the current system into files/.

Options:
  --dry-run    Print copy actions without changing the repository
  -h, --help   Show help
EOF
}

while (($#)); do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

log() {
  printf '[sync] %s\n' "$*"
}

run_cmd() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

copy_item() {
  local rel="$1"
  local src="$HOME/.config/$rel"
  local dst="$ROOT_DIR/files/config/$rel"

  if [[ ! -e "$src" && ! -L "$src" ]]; then
    log "skip missing ~/.config/$rel"
    return 0
  fi

  run_cmd mkdir -p -- "$(dirname -- "$dst")"
  run_cmd rm -rf -- "$dst"
  run_cmd cp -a -- "$src" "$dst"
}

copy_scripts() {
  local src="$HOME/scripts"
  local dst="$ROOT_DIR/files/scripts"

  if [[ ! -d "$src" ]]; then
    log "skip missing ~/scripts"
    return 0
  fi

  run_cmd rm -rf -- "$dst"
  run_cmd mkdir -p -- "$(dirname -- "$dst")"
  run_cmd cp -a -- "$src" "$dst"
}

remove_forbidden() {
  local forbidden=(
    "$ROOT_DIR/files/config/fish/secrets.fish"
    "$ROOT_DIR/files/config/fish/conf.d/rustup.fish"
    "$ROOT_DIR/files/config/opencode/opencode.json"
    "$ROOT_DIR/files/config/flclash"
    "$ROOT_DIR/files/config/google-chrome"
    "$ROOT_DIR/files/config/mozilla"
    "$ROOT_DIR/files/config/obsidian"
    "$ROOT_DIR/files/config/QQ"
    "$ROOT_DIR/files/config/MusicFree"
    "$ROOT_DIR/files/config/syncthing"
  )

  for path in "${forbidden[@]}"; do
    if [[ -e "$path" || -L "$path" ]]; then
      run_cmd rm -rf -- "$path"
    fi
  done

  while IFS= read -r -d '' git_dir; do
    run_cmd rm -rf -- "$git_dir"
  done < <(find "$ROOT_DIR/files" -type d -name .git -print0)
}

scan_secrets() {
  local forbidden_paths=(
    "$ROOT_DIR/files/config/fish/secrets.fish"
    "$ROOT_DIR/files/config/opencode/opencode.json"
  )
  local path

  for path in "${forbidden_paths[@]}"; do
    if [[ -e "$path" || -L "$path" ]]; then
      echo "[sync][error] Forbidden secret file copied: $path" >&2
      exit 1
    fi
  done

  local matches=""
  matches+="$(
    grep -RInE '-----BEGIN (RSA |OPENSSH |EC |DSA )?PRIVATE KEY-----' "$ROOT_DIR/files" 2>/dev/null || true
  )"
  matches+="$(
    grep -RInE '(sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{40,})' "$ROOT_DIR/files" 2>/dev/null || true
  )"
  matches+="$(
    grep -RInE '"apiKey"[[:space:]]*:[[:space:]]*"[^"]+"' "$ROOT_DIR/files/config" 2>/dev/null \
      | grep -Ev 'sk-your-key-here|your-api-key|your-google-api-key' || true
  )"

  if [[ -n "$matches" ]]; then
    printf '%s\n' "$matches" >&2
    echo "[sync][error] High-confidence secret content found under files/." >&2
    exit 1
  fi
}

main() {
  [[ -f "$CONFIG_MANIFEST" ]] || {
    echo "Missing manifest: $CONFIG_MANIFEST" >&2
    exit 1
  }

  while IFS= read -r rel; do
    [[ -z "$rel" || "$rel" =~ ^[[:space:]]*# ]] && continue
    copy_item "$rel"
  done <"$CONFIG_MANIFEST"

  copy_scripts
  remove_forbidden

  if [[ "$DRY_RUN" -ne 1 ]]; then
    scan_secrets
  fi

  log "sync complete"
}

main "$@"
