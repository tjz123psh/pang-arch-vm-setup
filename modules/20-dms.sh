#!/usr/bin/env bash

if [[ "$SKIP_DMS" -eq 1 ]]; then
  log "Skipping DMS installer"
  return 0
fi

log "DMS upstream installer will be downloaded and executed"
run_shell 'curl -fsSL https://install.danklinux.com | sh'
