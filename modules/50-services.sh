#!/usr/bin/env bash

system_units=(
  NetworkManager.service
  power-profiles-daemon.service
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

if systemctl list-unit-files sddm.service >/dev/null 2>&1; then
  for dm_unit in gdm.service lightdm.service ly.service greetd.service; do
    if systemctl list-unit-files "$dm_unit" >/dev/null 2>&1; then
      run_cmd sudo systemctl disable --now "$dm_unit"
    fi
  done
  run_cmd sudo systemctl enable --now sddm.service
else
  warn "System unit not found: sddm.service"
fi

# DMS owns notifications in this profile. Do not install mako; only disable
# and mask stale mako units when they already exist on the target system.
if systemctl --user list-unit-files mako.service >/dev/null 2>&1; then
  run_cmd systemctl --user disable mako.service
  run_cmd systemctl --user mask mako.service
  if [[ "$DRY_RUN" -eq 1 ]]; then
    run_cmd systemctl --user stop mako.service
  elif systemctl --user is-active --quiet mako.service; then
    run_cmd systemctl --user stop mako.service || warn "Failed to stop mako.service"
  else
    log "mako.service is not active; skipping stop"
  fi
fi

if systemctl --user list-unit-files >/dev/null 2>&1; then
  if ! run_cmd systemctl --user daemon-reload; then
    warn "Failed to reload systemd user manager"
  fi
else
  warn "systemd user manager is not available; skipping user services"
fi

for unit in "${user_units[@]}"; do
  if systemctl --user list-unit-files "$unit" >/dev/null 2>&1; then
    if [[ "$unit" == "dms.service" ]]; then
      if ! run_cmd systemctl --user enable "$unit"; then
        warn "Failed to enable user unit: $unit"
      fi
      if [[ "$DRY_RUN" -eq 1 ]] || systemctl --user is-active --quiet graphical-session.target; then
        if ! run_cmd systemctl --user start "$unit"; then
          warn "Failed to start user unit: $unit"
        fi
      else
        log "dms.service enabled; it will start on next graphical session"
      fi
    else
      if ! run_cmd systemctl --user enable "$unit"; then
        warn "Failed to enable user unit: $unit"
      fi
      if ! run_cmd systemctl --user start "$unit"; then
        warn "Failed to start user unit: $unit"
      fi
    fi
  else
    warn "User unit not found: $unit"
  fi
done
