#!/usr/bin/env bash

if [[ "$SKIP_DMS" -eq 1 ]]; then
  log "Skipping DMS installer"
  return 0
fi

restore_terminal_state() {
  if [[ -t 1 ]]; then
    tput rmcup 2>/dev/null || printf '\033[?1049l'
    tput cnorm 2>/dev/null || printf '\033[?25h'
    tput sgr0 2>/dev/null || printf '\033[0m'
    printf '\r'
  fi

  if [[ -t 0 ]]; then
    stty sane 2>/dev/null || true
  elif [[ -r /dev/tty ]]; then
    stty sane </dev/tty 2>/dev/null || true
  fi
}

install_dms_official_script() {
  local status

  if [[ -t 1 ]]; then
    log "Running DMS official installer from https://install.danklinux.com"
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    run_shell "curl -fsSL https://install.danklinux.com | sh"
    return 0
  fi

  restore_terminal_state
  curl -fsSL https://install.danklinux.com | sh
  status=$?
  restore_terminal_state
  return "$status"
}

if command -v dms >/dev/null 2>&1; then
  log "DMS already installed"
else
  log "Installing DMS with the official install.danklinux.com script"
  if ! install_dms_official_script; then
    die "DMS official installer failed"
  fi
fi

# Some DMS installers may start the user service immediately with default
# settings. Keep it stopped until user defaults have been restored, so the
# first real DMS start reads the repository-managed settings.
if [[ "$SKIP_DMS" -ne 1 ]] && systemctl --user list-unit-files dms.service >/dev/null 2>&1; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    run_cmd systemctl --user stop dms.service
  elif systemctl --user is-active --quiet dms.service; then
    if ! run_cmd systemctl --user stop dms.service; then
      warn "Failed to stop dms.service after install"
    fi
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    run_cmd systemctl --user reset-failed dms.service
  elif systemctl --user is-failed --quiet dms.service; then
    run_cmd systemctl --user reset-failed dms.service || warn "Failed to reset dms.service failed state"
  fi
fi

# Keep common DMS optional features available even when the package dependency
# set changes upstream.
if ! run_cmd sudo pacman -S --needed --noconfirm \
  matugen \
  cava \
  power-profiles-daemon \
  qt6-multimedia \
  qt6ct \
  wtype \
  cups-pk-helper \
  kimageformats; then
  warn "Failed to install one or more DMS optional dependencies"
fi

if [[ "$DRY_RUN" -ne 1 ]] && ! command -v dms >/dev/null 2>&1; then
  warn "DMS install finished, but dms command was not found"
fi
