#!/usr/bin/env bash

src_root="$ROOT_DIR/files/config"
dst_root="$HOME/.config"

if [[ ! -d "$src_root" ]]; then
  warn "No files/config directory yet; skipping dotfiles"
  return 0
fi

if ! find "$src_root" -mindepth 1 ! -name .keep -print -quit | grep -q .; then
  warn "files/config contains no installable items yet; skipping dotfiles"
  return 0
fi

# Copy the contents into ~/.config instead of replacing ~/.config itself.
# This keeps private files that are intentionally not committed, for example
# ~/.config/opencode/opencode.json and ~/.config/fish/secrets.fish.
sync_dir_contents "$src_root" "$dst_root"
