#!/usr/bin/env bash

pacman_list="$ROOT_DIR/config/pacman-packages.txt"
aur_list="$ROOT_DIR/config/aur-packages.txt"

ensure_paru() {
  if command -v paru >/dev/null 2>&1; then
    log "paru already installed"
    return 0
  fi

  log "paru not found; bootstrapping from AUR"
  # shellcheck disable=SC2016
  run_shell 'tmp="$(mktemp -d)"; trap '\''rm -rf "$tmp"'\'' EXIT; git clone https://aur.archlinux.org/paru.git "$tmp/paru"; cd "$tmp/paru"; makepkg -si --noconfirm'
}

mapfile -t pacman_packages < <(grep -Ev '^\s*(#|$)' "$pacman_list")
if ((${#pacman_packages[@]})); then
  run_cmd sudo pacman -S --needed --noconfirm "${pacman_packages[@]}"
fi

ensure_paru

mapfile -t aur_packages < <(grep -Ev '^\s*(#|$)' "$aur_list")
if ((${#aur_packages[@]})); then
  run_cmd paru -S --needed --noconfirm "${aur_packages[@]}"
fi
