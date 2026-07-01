#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${PANG_ARCH_VM_SETUP_REPO:-https://github.com/tjz123psh/pang-arch-vm-setup.git}"
REPO_DIR="${PANG_ARCH_VM_SETUP_DIR:-$HOME/projects/pang-arch-vm-setup}"

log() {
  printf '[bootstrap] %s\n' "$*"
}

die() {
  printf '[bootstrap][error] %s\n' "$*" >&2
  exit 1
}

require_arch() {
  [[ -r /etc/arch-release ]] || die "This bootstrap is for Arch Linux"
  [[ "$EUID" -ne 0 ]] || die "Run as a normal user with sudo access, not as root"
  command -v sudo >/dev/null 2>&1 || die "sudo is required"
}

ensure_base_tools() {
  local missing=()
  local cmd

  for cmd in git curl; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing+=("$cmd")
    fi
  done

  if ((${#missing[@]})); then
    log "Installing base tools: ${missing[*]}"
    sudo pacman -Syu --needed --noconfirm git curl ca-certificates sudo
  fi
}

sync_repo() {
  if [[ -d "$REPO_DIR/.git" ]]; then
    log "Updating existing repository: $REPO_DIR"
    git -C "$REPO_DIR" pull --ff-only
    return 0
  fi

  if [[ -e "$REPO_DIR" ]]; then
    die "Target path exists but is not a git repository: $REPO_DIR"
  fi

  log "Cloning repository: $REPO_URL"
  mkdir -p -- "$(dirname -- "$REPO_DIR")"
  git clone "$REPO_URL" "$REPO_DIR"
}

main() {
  require_arch
  ensure_base_tools
  sync_repo

  log "Running installer"
  exec "$REPO_DIR/install.sh" "$@"
}

main "$@"
