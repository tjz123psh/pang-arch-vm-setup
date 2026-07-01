#!/usr/bin/env bash

if [[ "$SKIP_DMS" -eq 1 ]]; then
  log "Skipping DMS installer"
  return 0
fi

if command -v dms >/dev/null 2>&1; then
  log "DMS already installed; skipping upstream installer"
else
  log "DMS upstream installer will be downloaded and executed"
  run_shell 'curl -fsSL https://install.danklinux.com | sh' \
    || die "DMS upstream installer failed; retry later or run with --skip-dms"
fi

# The upstream installer assumes the compositor adapter dependency is already
# satisfied. Install the niri adapter explicitly so DMS gets niri integration.
run_cmd sudo pacman -S --needed --noconfirm dms-shell-niri
