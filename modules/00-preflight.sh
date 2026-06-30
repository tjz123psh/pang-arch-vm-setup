#!/usr/bin/env bash

[[ "$(uname -m)" == "x86_64" ]] || die "Only x86_64 is supported for now"
[[ -r /etc/arch-release ]] || die "This installer is for Arch Linux"
[[ "$PROFILE" == "vm" ]] || die "Only profile=vm is implemented"

require_cmd pacman
require_cmd sudo
require_cmd curl

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

log "Preflight passed"
