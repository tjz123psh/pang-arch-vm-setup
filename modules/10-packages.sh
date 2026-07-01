#!/usr/bin/env bash

pacman_list="$ROOT_DIR/config/pacman-packages.txt"
aur_list="$ROOT_DIR/config/aur-packages.txt"
app_pacman_list="$ROOT_DIR/config/app-pacman-packages.txt"
app_aur_list="$ROOT_DIR/config/app-aur-packages.txt"

read_package_list() {
  local list="$1"

  [[ -f "$list" ]] || return 0
  grep -Ev '^\s*(#|$)' "$list"
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
if [[ "$WITH_APPS" -eq 1 ]]; then
  mapfile -t app_pacman_packages < <(read_package_list "$app_pacman_list")
  pacman_packages+=("${app_pacman_packages[@]}")
fi
if ((${#pacman_packages[@]})); then
  run_cmd sudo pacman -S --needed --noconfirm "${pacman_packages[@]}"
fi

ensure_paru

mapfile -t aur_packages < <(read_package_list "$aur_list")
if [[ "$WITH_APPS" -eq 1 ]]; then
  mapfile -t app_aur_packages < <(read_package_list "$app_aur_list")
  aur_packages+=("${app_aur_packages[@]}")
fi
if ((${#aur_packages[@]})); then
  run_cmd paru -S --needed --noconfirm "${aur_packages[@]}"
fi
