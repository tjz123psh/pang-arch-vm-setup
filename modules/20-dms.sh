#!/usr/bin/env bash

if [[ "$SKIP_DMS" -eq 1 ]]; then
  log "Skipping DMS installer"
  return 0
fi

if command -v dms >/dev/null 2>&1; then
  log "DMS already installed; skipping official installer"
else
  log "DMS official installer will be downloaded and executed"
  if ! run_shell 'curl -fsSL https://install.danklinux.com | bash'; then
    warn "DMS official installer failed; falling back to Arch package dms-shell-niri"
    run_cmd sudo pacman -S --needed --noconfirm dms-shell-niri
  fi
fi

# Keep common DMS optional features available even when the official installer
# changes behavior or the fallback path is used.
run_cmd sudo pacman -S --needed --noconfirm \
  matugen \
  cava \
  power-profiles-daemon \
  qt6-multimedia \
  qt6ct \
  wtype \
  cups-pk-helper \
  kimageformats

if [[ "$DRY_RUN" -ne 1 ]] && ! command -v dms >/dev/null 2>&1; then
  die "DMS install finished, but dms command was not found"
fi
