#!/usr/bin/env bash

[[ "$(uname -m)" == "x86_64" ]] || die "Only x86_64 is supported for now"
[[ -r /etc/arch-release ]] || die "This installer is for Arch Linux"
[[ "$PROFILE" == "vm" ]] || die "Only profile=vm is implemented"

require_cmd pacman
require_cmd sudo
require_cmd curl

ensure_pacman_mirrors() {
  local source_mirrorlist="$ROOT_DIR/config/pacman-mirrorlist"
  local target_mirrorlist="/etc/pacman.d/mirrorlist"
  local backup

  [[ -f "$source_mirrorlist" ]] || die "Missing pacman mirrorlist template: $source_mirrorlist"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "Dry-run: would install pacman mirrorlist and refresh sync databases"
    run_cmd sudo cp -a -- "$target_mirrorlist" "${target_mirrorlist}.bak-TIMESTAMP"
    run_cmd sudo install -Dm644 -- "$source_mirrorlist" "$target_mirrorlist"
    run_cmd sudo pacman -Syy --noconfirm
    return 0
  fi

  if sudo cmp -s -- "$source_mirrorlist" "$target_mirrorlist"; then
    log "Pacman mirrorlist already matches VM defaults"
  else
    backup="${target_mirrorlist}.bak-$(date +%Y%m%d-%H%M%S)"
    if [[ -e "$target_mirrorlist" || -L "$target_mirrorlist" ]]; then
      log "Backing up $target_mirrorlist -> $backup"
      sudo cp -a -- "$target_mirrorlist" "$backup"
    fi
    log "Installing VM pacman mirrorlist"
    sudo install -Dm644 -- "$source_mirrorlist" "$target_mirrorlist"
  fi

  log "Refreshing pacman sync databases"
  sudo pacman -Syy --noconfirm
}

if ! ping -c 1 -W 3 archlinux.org >/dev/null 2>&1; then
  warn "Network ping to archlinux.org failed; package install may fail"
fi

if [[ "$EUID" -eq 0 ]]; then
  die "Run as a normal user with sudo access, not as root"
fi

if [[ "$DRY_RUN" -ne 1 ]]; then
  if ! sudo -v; then
    die "sudo is required"
  fi
else
  log "Dry-run: skipping sudo credential check"
fi

ensure_pacman_mirrors

log "Preflight passed"
