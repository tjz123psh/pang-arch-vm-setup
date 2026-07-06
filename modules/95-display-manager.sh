#!/usr/bin/env bash

if systemctl list-unit-files sddm.service >/dev/null 2>&1; then
  if systemctl is-active --quiet sddm.service; then
    log "sddm.service is already active"
  else
    run_cmd sudo systemctl start sddm.service
  fi
else
  warn "System unit not found: sddm.service"
fi
