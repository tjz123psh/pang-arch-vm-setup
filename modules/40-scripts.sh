#!/usr/bin/env bash

src="$ROOT_DIR/files/scripts"
dst="$HOME/scripts"

if [[ ! -d "$src" ]]; then
  warn "No files/scripts directory yet; skipping scripts"
  return 0
fi

if ! find "$src" -type f ! -name .keep -print -quit | grep -q .; then
  warn "files/scripts contains no scripts yet; skipping scripts"
  return 0
fi

install_file_or_dir "$src" "$dst"

bin_dir="$HOME/.local/bin"
run_cmd mkdir -p "$bin_dir"

for entry in b23 check-battery niri-keys cache-clean pak pacd pacr pacrrr paru-ui; do
  target="$(find "$dst" -type f -name "$entry" -perm -111 | head -n 1)"
  if [[ -n "$target" ]]; then
    run_cmd ln -sfn "$target" "$bin_dir/$entry"
  else
    warn "Script entry not found: $entry"
  fi
done
