#!/usr/bin/env bash

system_units=(
  NetworkManager.service
  vmtoolsd.service
  vmware-vmblock-fuse.service
)

user_units=(
  dsearch.service
)

if [[ "$SKIP_DMS" -ne 1 ]]; then
  user_units+=(dms.service)
fi

for unit in "${system_units[@]}"; do
  if systemctl list-unit-files "$unit" >/dev/null 2>&1; then
    run_cmd sudo systemctl enable --now "$unit"
  else
    warn "System unit not found: $unit"
  fi
done

if systemctl --user list-unit-files mako.service >/dev/null 2>&1; then
  run_cmd systemctl --user disable --now mako.service
fi

for unit in "${user_units[@]}"; do
  if systemctl --user list-unit-files "$unit" >/dev/null 2>&1; then
    run_cmd systemctl --user enable --now "$unit"
  else
    warn "User unit not found: $unit"
  fi
done
