#!/usr/bin/env bash

system_units=(
  NetworkManager.service
)

user_units=(
  dms.service
  dsearch.service
)

for unit in "${system_units[@]}"; do
  if systemctl list-unit-files "$unit" >/dev/null 2>&1; then
    run_cmd sudo systemctl enable --now "$unit"
  else
    warn "System unit not found: $unit"
  fi
done

for unit in "${user_units[@]}"; do
  if systemctl --user list-unit-files "$unit" >/dev/null 2>&1; then
    run_cmd systemctl --user enable --now "$unit"
  else
    warn "User unit not found: $unit"
  fi
done
