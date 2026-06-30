#!/usr/bin/env bash

src_root="$ROOT_DIR/files/config"
dst_root="$HOME/.config"

if [[ ! -d "$src_root" ]]; then
  warn "No files/config directory yet; skipping dotfiles"
  return 0
fi

has_items=0
while IFS= read -r -d '' item; do
  has_items=1
  rel="${item#"$src_root"/}"
  install_file_or_dir "$item" "$dst_root/$rel"
done < <(find "$src_root" -mindepth 1 -maxdepth 1 ! -name .keep -print0)

if [[ "$has_items" -eq 0 ]]; then
  warn "files/config contains no installable items yet; skipping dotfiles"
fi
