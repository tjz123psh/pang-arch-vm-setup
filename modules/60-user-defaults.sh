#!/usr/bin/env bash

applications_src="$ROOT_DIR/files/applications"
applications_dst="$HOME/.local/share/applications"

if [[ -d "$applications_src" ]]; then
  sync_dir_contents "$applications_src" "$applications_dst"
fi

if command -v xdg-mime >/dev/null 2>&1; then
  if [[ -f "$applications_dst/nvim.desktop" || -f "$applications_src/nvim.desktop" ]]; then
    run_cmd xdg-mime default nvim.desktop text/plain
  fi

  if [[ -f /usr/share/applications/org.gnome.Nautilus.desktop ]]; then
    run_cmd xdg-mime default org.gnome.Nautilus.desktop inode/directory
  fi
fi

rime_user_yaml="$HOME/.local/share/fcitx5/rime/user.yaml"
if [[ -f "$rime_user_yaml" ]]; then
  run_cmd sed -i '/^[[:space:]]*previously_selected_schema:/d' "$rime_user_yaml"
fi

rustup_fish="$HOME/.config/fish/conf.d/rustup.fish"
rustup_source_line="source \"\$HOME/.cargo/env.fish\""
if [[ ! -e "$HOME/.cargo/env.fish" && -f "$rustup_fish" ]] \
  && grep -Fxq "$rustup_source_line" "$rustup_fish"; then
  run_cmd rm -f "$rustup_fish"
fi

if command -v fish >/dev/null 2>&1; then
  fish_path="$(command -v fish)"
  current_shell="$(getent passwd "$USER" | cut -d: -f7)"

  if [[ "$current_shell" != "$fish_path" ]]; then
    run_cmd chsh -s "$fish_path" "$USER"
  fi
fi
