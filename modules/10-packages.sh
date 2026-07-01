#!/usr/bin/env bash

pacman_list="$ROOT_DIR/config/pacman-packages.txt"
aur_list="$ROOT_DIR/config/aur-packages.txt"

read_package_list() {
  local list="$1"

  [[ -f "$list" ]] || return 0
  grep -Ev '^\s*(#|$)' "$list"
}

filter_aur_packages() {
  local -n packages_ref="$1"
  local filtered=()
  local pkg
  local flclash_installed=0

  if pacman -Q flclash-appimage-bin >/dev/null 2>&1 \
    || pacman -Q flclash-bin >/dev/null 2>&1 \
    || pacman -Q flclash >/dev/null 2>&1; then
    flclash_installed=1
  fi

  for pkg in "${packages_ref[@]}"; do
    case "$pkg" in
      flclash | flclash-bin | flclash-appimage-bin)
        if [[ "$flclash_installed" -eq 1 ]]; then
          log "FlClash is already installed; skipping $pkg"
          continue
        fi
        ;;
    esac
    filtered+=("$pkg")
  done

  packages_ref=("${filtered[@]}")
}

ensure_paru() {
  if command -v paru >/dev/null 2>&1; then
    log "paru already installed"
    return 0
  fi

  log "paru not found; bootstrapping from AUR"
  # shellcheck disable=SC2016
  run_shell 'tmp="$(mktemp -d)"; trap '\''rm -rf "$tmp"'\'' EXIT; git clone https://aur.archlinux.org/paru.git "$tmp/paru"; cd "$tmp/paru"; makepkg -si --noconfirm'
}

mapfile -t pacman_packages < <(read_package_list "$pacman_list")
if ((${#pacman_packages[@]})); then
  run_cmd sudo pacman -S --needed --noconfirm "${pacman_packages[@]}"
fi

ensure_paru

mapfile -t aur_packages < <(read_package_list "$aur_list")
filter_aur_packages aur_packages
if ((${#aur_packages[@]})); then
  run_cmd paru -S --needed --noconfirm --skipreview "${aur_packages[@]}"
fi
