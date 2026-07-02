#!/usr/bin/env bash

if [[ "$SKIP_DMS" -eq 1 ]]; then
  log "Skipping DMS installer"
  return 0
fi

dms_installer_arch() {
  case "$(uname -m)" in
    x86_64)
      printf 'amd64\n'
      ;;
    aarch64)
      printf 'arm64\n'
      ;;
    *)
      return 1
      ;;
  esac
}

dms_latest_version() {
  local latest_url version

  latest_url="$(curl -fsSLI -o /dev/null -w '%{url_effective}' \
    https://github.com/AvengeMedia/DankMaterialShell/releases/latest)" || return 1
  version="${latest_url##*/}"
  [[ "$version" == v* ]] || return 1
  printf '%s\n' "$version"
}

install_dms_official_release() {
  local arch version tmp_dir expected actual status

  if [[ "$DRY_RUN" -eq 1 ]]; then
    # shellcheck disable=SC2016
    run_shell 'version="$(curl -fsSLI -o /dev/null -w '\''%{url_effective}'\'' https://github.com/AvengeMedia/DankMaterialShell/releases/latest)"; version="${version##*/}"; tmp="$(mktemp -d)"; curl -fL "https://github.com/AvengeMedia/DankMaterialShell/releases/download/$version/dankinstall-amd64.gz" -o "$tmp/installer.gz"; curl -fL "https://github.com/AvengeMedia/DankMaterialShell/releases/download/$version/dankinstall-amd64.gz.sha256" -o "$tmp/expected.sha256"; sha256sum -c "$tmp/expected.sha256"; gunzip "$tmp/installer.gz"; chmod +x "$tmp/installer"; "$tmp/installer"'
    return 0
  fi

  arch="$(dms_installer_arch)" || return 1
  version="$(dms_latest_version)" || return 1
  tmp_dir="$(mktemp -d)" || return 1
  status=0

  log "Installing DMS official release $version for $arch"
  if ! curl -fL "https://github.com/AvengeMedia/DankMaterialShell/releases/download/$version/dankinstall-$arch.gz" -o "$tmp_dir/installer.gz"; then
    status=1
  elif ! curl -fL "https://github.com/AvengeMedia/DankMaterialShell/releases/download/$version/dankinstall-$arch.gz.sha256" -o "$tmp_dir/expected.sha256"; then
    status=1
  else
    expected="$(awk '{ print $1 }' "$tmp_dir/expected.sha256")"
    actual="$(sha256sum "$tmp_dir/installer.gz" | awk '{ print $1 }')"
    if [[ "$expected" != "$actual" ]]; then
      warn "DMS installer checksum mismatch"
      status=1
    elif ! gunzip "$tmp_dir/installer.gz"; then
      status=1
    else
      chmod +x "$tmp_dir/installer"
      "$tmp_dir/installer" || status=1
    fi
  fi

  rm -rf -- "$tmp_dir"
  return "$status"
}

if command -v dms >/dev/null 2>&1; then
  log "DMS already installed"
else
  log "Installing DMS from the official release installer without GitHub API"
  if ! install_dms_official_release; then
    warn "DMS official release installer failed; falling back to Arch package dms-shell-niri"
    if ! run_cmd sudo pacman -S --needed --noconfirm dms-shell-niri; then
      warn "DMS pacman install failed; continuing so user defaults stay deployed"
    fi
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
