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

user_dirs=(
  Desktop
  Downloads
  Templates
  Public
  Documents
  Music
  Pictures
  Videos
  Projects
)

for user_dir in "${user_dirs[@]}"; do
  run_cmd mkdir -p -- "$HOME/$user_dir"
done

if command -v xdg-user-dirs-update >/dev/null 2>&1; then
  run_cmd xdg-user-dirs-update
fi

rime_user_yaml="$HOME/.local/share/fcitx5/rime/user.yaml"
rime_config_src="$ROOT_DIR/files/config/fcitx5/rime"
rime_data_dst="$HOME/.local/share/fcitx5/rime"
if [[ -d "$rime_config_src" ]]; then
  sync_dir_contents "$rime_config_src" "$rime_data_dst"
fi

if [[ -f "$rime_user_yaml" ]]; then
  run_cmd sed -i '/previously_selected_schema:/d' "$rime_user_yaml"
fi

run_cmd mkdir -p -- "$(dirname -- "$rime_user_yaml")"
# shellcheck disable=SC2016
run_shell 'printf "%s\n" "var:" "  previously_selected_schema: rime_ice" > "$HOME/.local/share/fcitx5/rime/user.yaml"'

stale_luna_custom="$HOME/.config/fcitx5/rime/luna_pinyin.custom.yaml"
if [[ -f "$stale_luna_custom" ]]; then
  run_cmd rm -f "$stale_luna_custom"
fi

stale_luna_data_custom="$HOME/.local/share/fcitx5/rime/luna_pinyin.custom.yaml"
if [[ -f "$stale_luna_data_custom" ]]; then
  run_cmd rm -f "$stale_luna_data_custom"
fi

rustup_fish="$HOME/.config/fish/conf.d/rustup.fish"
rustup_source_line="source \"\$HOME/.cargo/env.fish\""
if [[ ! -e "$HOME/.cargo/env.fish" && -f "$rustup_fish" ]] \
  && grep -Fxq "$rustup_source_line" "$rustup_fish"; then
  run_cmd rm -f "$rustup_fish"
fi

stale_fcitx_env="$HOME/.config/environment.d/80-fcitx5.conf"
if [[ -f "$stale_fcitx_env" ]]; then
  run_cmd rm -f "$stale_fcitx_env"
fi

if [[ -f "$HOME/.profile" ]] && grep -q "# BEGIN pang fcitx5 env" "$HOME/.profile"; then
  # shellcheck disable=SC2016
  run_shell 'profile="$HOME/.profile"; tmp="$(mktemp)"; sed "/# BEGIN pang fcitx5 env/,/# END pang fcitx5 env/d" "$profile" > "$tmp"; cat "$tmp" > "$profile"; rm -f "$tmp"'
fi

bad_nvim_color_plugin="$HOME/.config/nvim/lua/plugins/dankcolors.lua"
if [[ -f "$bad_nvim_color_plugin" ]]; then
  run_cmd rm -f "$bad_nvim_color_plugin"
fi

bad_nvim_color_package="$HOME/.local/share/nvim/lazy/base16-nvim"
if [[ -d "$bad_nvim_color_package" ]]; then
  run_cmd rm -rf "$bad_nvim_color_package"
fi

if command -v fish >/dev/null 2>&1; then
  fish_path="$(command -v fish)"
  current_shell="$(getent passwd "$USER" | cut -d: -f7)"

  if [[ "$current_shell" != "$fish_path" ]]; then
    run_cmd chsh -s "$fish_path" "$USER"
  fi
fi

if getent group input >/dev/null 2>&1 && ! id -nG "$USER" | tr " " "\n" | grep -Fxq input; then
  run_cmd sudo usermod -aG input "$USER"
  warn "Added $USER to input group; log out and log back in for this permission to take effect"
fi
