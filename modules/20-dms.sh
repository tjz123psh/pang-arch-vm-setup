#!/usr/bin/env bash

if [[ "$SKIP_DMS" -eq 1 ]]; then
  log "Skipping DMS package installation"
  return 0
fi

dms_packages=(
  dms-shell-niri
  matugen
  cava
  power-profiles-daemon
  qt6-multimedia
  qt6ct
  wtype
  cups-pk-helper
  kimageformats
)

log "Installing DMS from Arch package dms-shell-niri"
if ! run_cmd sudo pacman -S --needed --noconfirm "${dms_packages[@]}"; then
  die "DMS Arch package install failed"
fi

if [[ "$DRY_RUN" -ne 1 ]] && ! command -v dms >/dev/null 2>&1; then
  die "DMS install finished, but dms command was not found"
fi

# Keep DMS stopped until repository-managed configs are restored, so the first
# real DMS start reads this profile's settings, niri config, and kitty config.
if systemctl --user list-unit-files dms.service >/dev/null 2>&1; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    run_cmd systemctl --user stop dms.service
  elif systemctl --user is-active --quiet dms.service; then
    if ! run_cmd systemctl --user stop dms.service; then
      warn "Failed to stop dms.service after package install"
    fi
  fi
fi
