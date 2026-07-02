#!/usr/bin/env bash

if [[ "$SKIP_DMS" -eq 1 ]]; then
  log "Skipping DMS package install"
  return 0
fi

run_cmd sudo pacman -S --needed --noconfirm dms-shell-niri

if [[ "$DRY_RUN" -ne 1 ]] && ! command -v dms >/dev/null 2>&1; then
  die "DMS package install finished, but dms command was not found"
fi
