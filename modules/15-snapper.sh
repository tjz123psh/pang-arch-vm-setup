#!/usr/bin/env bash

if ! command -v snapper >/dev/null 2>&1; then
  warn "snapper command not found; skipping Snapper setup"
  return 0
fi

if ! command -v findmnt >/dev/null 2>&1; then
  warn "findmnt command not found; skipping Snapper setup"
  return 0
fi

snapper_has_config() {
  local conf="$1"

  if [[ -f "/etc/snapper/configs/$conf" ]]; then
    return 0
  fi

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    return 1
  fi

  sudo snapper -c "$conf" get-config >/dev/null 2>&1
}

ensure_snapper_config() {
  local conf="$1"
  local path="$2"

  if [[ ! -d "$path" ]]; then
    warn "Snapper target directory does not exist: $path"
    return 0
  fi

  if [[ "$(findmnt -T "$path" -no FSTYPE 2>/dev/null || true)" != "btrfs" ]]; then
    log "Snapper target is not Btrfs; skipping $conf: $path"
    return 0
  fi

  if snapper_has_config "$conf"; then
    log "Snapper config already exists: $conf"
  else
    log "Creating Snapper config: $conf -> $path"
    run_cmd sudo snapper -c "$conf" create-config "$path"
  fi

  run_cmd sudo snapper -c "$conf" set-config \
    ALLOW_GROUPS="wheel" \
    SYNC_ACL="yes" \
    NUMBER_LIMIT="10" \
    NUMBER_MIN_AGE="0"
}

ensure_snapper_config root /

home_mount="$(findmnt -T "$HOME" -no TARGET 2>/dev/null || true)"
if [[ "$home_mount" == "/home" ]]; then
  ensure_snapper_config home /home
else
  log "Home is not a separate mount; root Snapper config covers $HOME"
fi
