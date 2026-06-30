#!/usr/bin/env bash

log() {
  printf '[setup] %s\n' "$*"
}

warn() {
  printf '[setup][warn] %s\n' "$*" >&2
}

die() {
  printf '[setup][error] %s\n' "$*" >&2
  exit 1
}

run_cmd() {
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

run_shell() {
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    printf '[dry-run] %s\n' "$*"
    return 0
  fi
  bash -c "$*"
}

confirm() {
  local prompt="${1:-Continue?}"
  read -r -p "$prompt [y/N] " answer
  case "$answer" in
    y | Y | yes | YES)
      ;;
    *)
      die "Aborted"
      ;;
  esac
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

run_module() {
  local module="$1"
  log "Running module: $module"
  # shellcheck source=/dev/null
  source "$ROOT_DIR/modules/$module"
}

backup_path() {
  local path="$1"
  [[ -e "$path" || -L "$path" ]] || return 0

  local backup
  backup="${path}.bak-$(date +%Y%m%d-%H%M%S)"
  log "Backing up $path -> $backup"
  run_cmd mv -- "$path" "$backup"
}

same_path() {
  local src="$1"
  local dst="$2"

  [[ -e "$dst" || -L "$dst" ]] || return 1

  if [[ -f "$src" && -f "$dst" ]]; then
    cmp -s -- "$src" "$dst"
    return $?
  fi

  if [[ -L "$src" && -L "$dst" ]]; then
    [[ "$(readlink -- "$src")" == "$(readlink -- "$dst")" ]]
    return $?
  fi

  return 1
}

install_file_or_dir() {
  local src="$1"
  local dst="$2"

  [[ -e "$src" ]] || die "Source does not exist: $src"

  if [[ -d "$src" && -d "$dst" ]]; then
    sync_dir_contents "$src" "$dst"
    return 0
  fi

  if same_path "$src" "$dst"; then
    log "Unchanged: $dst"
    return 0
  fi

  backup_path "$dst"
  run_cmd mkdir -p -- "$(dirname -- "$dst")"
  run_cmd cp -a -- "$src" "$dst"
}

sync_dir_contents() {
  local src="$1"
  local dst="$2"

  [[ -d "$src" ]] || die "Source directory does not exist: $src"
  run_cmd mkdir -p -- "$dst"

  local item
  while IFS= read -r -d '' item; do
    install_file_or_dir "$item" "$dst/$(basename -- "$item")"
  done < <(find "$src" -mindepth 1 -maxdepth 1 ! -name .keep -print0)
}
