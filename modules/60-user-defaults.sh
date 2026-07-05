#!/usr/bin/env bash

applications_src="$ROOT_DIR/files/applications"
applications_dst="$HOME/.local/share/applications"

restore_dms_managed_configs() {
  local src_config="$ROOT_DIR/files/config"

  if [[ -d "$src_config/niri" ]]; then
    sync_dir_contents "$src_config/niri" "$HOME/.config/niri"
  fi

  if [[ -d "$src_config/kitty" ]]; then
    sync_dir_contents "$src_config/kitty" "$HOME/.config/kitty"
  fi

  if [[ -f "$src_config/DankMaterialShell/settings.json" ]]; then
    install_file_or_dir "$src_config/DankMaterialShell/settings.json" \
      "$HOME/.config/DankMaterialShell/settings.json"
  fi
}

restore_dms_managed_configs

if [[ -d "$applications_src" ]]; then
  sync_dir_contents "$applications_src" "$applications_dst"
fi

if command -v xdg-mime >/dev/null 2>&1; then
  if [[ -f "$applications_dst/nvim.desktop" || -f "$applications_src/nvim.desktop" ]]; then
    if ! run_cmd xdg-mime default nvim.desktop text/plain; then
      warn "Failed to set text/plain MIME default to nvim.desktop"
    fi
  else
    warn "nvim.desktop is missing; cannot set text/plain MIME default"
  fi

  if [[ -f /usr/share/applications/org.gnome.Nautilus.desktop ]]; then
    if ! run_cmd xdg-mime default org.gnome.Nautilus.desktop inode/directory; then
      warn "Failed to set directory MIME default to Nautilus"
    fi
  else
    warn "Nautilus desktop entry is missing; cannot set directory MIME default"
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
rime_config_dst="$HOME/.config/fcitx5/rime"
wanxiang_grammar="wanxiang-lts-zh-hans.gram"

ensure_wanxiang_grammar() {
  local dst="$rime_data_dst/$wanxiang_grammar"
  local url="https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/$wanxiang_grammar"

  if [[ -f "/usr/share/rime-data/$wanxiang_grammar" || -f "$dst" ]]; then
    return 0
  fi

  warn "$wanxiang_grammar is missing; downloading fallback grammar model"
  run_cmd curl -fL --retry 3 --retry-delay 2 --connect-timeout 15 --max-time 1800 \
    "$url" -o "$dst"
}

restore_rime_configs() {
  local target="$1"
  local stale_file

  run_cmd mkdir -p -- "$target"

  for stale_file in \
    "$target/default.yaml" \
    "$target/default.custom.yaml" \
    "$target/luna_pinyin.custom.yaml" \
    "$target/luna_pinyin_simp.custom.yaml" \
    "$target/luna_pinyin_fluency.custom.yaml"; do
    if [[ -e "$stale_file" || -L "$stale_file" ]]; then
      run_cmd rm -f -- "$stale_file"
    fi
  done

  if [[ -d "$rime_config_src" ]]; then
    sync_dir_contents "$rime_config_src" "$target"
  fi
}

restore_rime_configs "$rime_config_dst"
restore_rime_configs "$rime_data_dst"

run_cmd mkdir -p -- "$(dirname -- "$rime_user_yaml")"
ensure_wanxiang_grammar

if command -v rime_deployer >/dev/null 2>&1; then
  # shellcheck disable=SC2016
  run_shell 'cd "$HOME/.local/share/fcitx5/rime" && rime_deployer --set-active-schema rime_ice'
  # shellcheck disable=SC2016
  run_shell 'user_yaml="$HOME/.local/share/fcitx5/rime/user.yaml"; now="$(date +%s)"; printf "%s\n" "var:" "  previously_selected_schema: rime_ice" "  schema_access_time:" "    rime_ice: $now" > "$user_yaml"'
  run_cmd rm -rf -- "$rime_data_dst/build"
  run_cmd mkdir -p -- "$rime_data_dst/build"
  run_cmd rime_deployer --build "$rime_data_dst" /usr/share/rime-data "$rime_data_dst/build"
elif [[ ! -f "$rime_user_yaml" ]]; then
  # shellcheck disable=SC2016
  run_shell 'printf "%s\n" "var:" "  previously_selected_schema: rime_ice" > "$HOME/.local/share/fcitx5/rime/user.yaml"'
fi

restart_fcitx5_with_rime() {
  if ! command -v fcitx5-remote >/dev/null 2>&1 || ! command -v fcitx5 >/dev/null 2>&1; then
    return 0
  fi

  if fcitx5-remote --check >/dev/null 2>&1; then
    run_cmd fcitx5-remote -r || warn "Failed to reload fcitx5 config"
    run_cmd fcitx5-remote -s rime || warn "Failed to switch fcitx5 input method to rime"
    run_cmd fcitx5-remote -e || warn "Failed to stop fcitx5 for config reload"
    if [[ "$DRY_RUN" -ne 1 ]]; then
      sleep 1
    fi
  fi

  if [[ -n "${WAYLAND_DISPLAY:-}" || -n "${DISPLAY:-}" ]]; then
    run_shell 'setsid fcitx5 -d >/dev/null 2>&1 || fcitx5 -d >/dev/null 2>&1'
    if [[ "$DRY_RUN" -ne 1 ]]; then
      sleep 1
    fi
    run_cmd fcitx5-remote -s rime || warn "Failed to switch restarted fcitx5 input method to rime"
  else
    warn "No graphical display detected; log out and back in to load the restored Rime config"
  fi
}

restart_fcitx5_with_rime

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
    if ! run_cmd sudo usermod --shell "$fish_path" "$USER"; then
      warn "Failed to change default shell to $fish_path"
    fi
  fi
fi

if getent group input >/dev/null 2>&1 && ! id -nG "$USER" | tr " " "\n" | grep -Fxq input; then
  if run_cmd sudo usermod -aG input "$USER"; then
    warn "Added $USER to input group; log out and log back in for this permission to take effect"
  else
    warn "Failed to add $USER to input group"
  fi
fi

if [[ "$SKIP_DMS" -ne 1 ]] && systemctl --user list-unit-files dms.service >/dev/null 2>&1; then
  if systemctl --user is-active --quiet graphical-session.target; then
    if run_cmd systemctl --user start dms.service; then
      log "dms.service started with restored configs"
    else
      die "Failed to start dms.service after restoring configs"
    fi
  else
    log "graphical-session.target is not active; dms.service will start on next graphical login"
  fi
fi
