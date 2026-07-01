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

# DMS owns notifications in this profile. Do not install mako; only disable
# stale mako units when they already exist on the target system.
if systemctl --user list-unit-files mako.service >/dev/null 2>&1; then
  run_cmd systemctl --user disable mako.service
  if [[ "$DRY_RUN" -eq 1 ]]; then
    run_cmd systemctl --user stop mako.service
  elif systemctl --user is-active --quiet mako.service; then
    run_cmd systemctl --user stop mako.service || warn "Failed to stop mako.service"
  else
    log "mako.service is not active; skipping stop"
  fi
fi

for unit in "${user_units[@]}"; do
  if systemctl --user list-unit-files "$unit" >/dev/null 2>&1; then
    run_cmd systemctl --user enable --now "$unit"
  else
    warn "User unit not found: $unit"
  fi
done
