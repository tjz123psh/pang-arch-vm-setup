#!/usr/bin/env bash

if [[ "$SKIP_DMS" -eq 1 ]]; then
  log "Skipping DMS installer"
  return 0
fi

log "DMS upstream installer will be downloaded and executed"
run_shell 'curl -fsSL https://install.danklinux.com | sh'

# The upstream installer assumes the compositor adapter dependency is already
# satisfied. Install the niri adapter explicitly so DMS gets niri integration.
run_cmd sudo pacman -S --needed --noconfirm dms-shell-niri
