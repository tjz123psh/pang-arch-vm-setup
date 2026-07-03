#!/usr/bin/env bash

if command -v fish >/dev/null 2>&1 && [[ -f "$HOME/.config/fish/config.fish" ]]; then
  run_cmd fish -n "$HOME/.config/fish/config.fish"
fi

if command -v nvim >/dev/null 2>&1; then
  run_cmd nvim --headless '+lua print("nvim ok")' +qa
fi

if command -v niri >/dev/null 2>&1 && [[ -f "$HOME/.config/niri/config.kdl" ]]; then
  run_cmd niri validate -c "$HOME/.config/niri/config.kdl"
fi

if command -v opencode >/dev/null 2>&1; then
  run_shell "opencode debug config >/dev/null"
fi

if [[ -x "$HOME/scripts/package/paru-ui" ]]; then
  run_shell "'$HOME/scripts/package/paru-ui' --help >/dev/null"
else
  warn "paru-ui script not found or not executable: $HOME/scripts/package/paru-ui"
fi

if [[ -x "$HOME/.local/bin/paru-ui" ]]; then
  log "paru-ui command link exists"
else
  warn "paru-ui command link missing: $HOME/.local/bin/paru-ui"
fi

if [[ -d "$HOME/scripts" ]]; then
  run_shell "find '$HOME/scripts' -type f -perm -111 -print | sort | xargs -r bash -n"
fi

if [[ "$DRY_RUN" -ne 1 ]]; then
  if [[ "$SKIP_DMS" -ne 1 ]] && ! command -v dms >/dev/null 2>&1; then
    die "DMS command missing; rerun after pacman can install dms-shell-niri or use --skip-dms for base setup only"
  fi

  if ! cmp -s "$ROOT_DIR/files/config/niri/config.kdl" "$HOME/.config/niri/config.kdl"; then
    die "niri config does not match repository version"
  fi

  if grep -Eq '^[[:space:]]*include[[:space:]]+"dms/binds.kdl"' "$HOME/.config/niri/config.kdl"; then
    die "niri config must not include DMS-generated dms/binds.kdl"
  fi

  if ! grep -Eq '^[[:space:]]*include[[:space:]]+"dms/keybinds.kdl"' "$HOME/.config/niri/config.kdl"; then
    die "niri config must include repository dms/keybinds.kdl"
  fi

  if ! cmp -s "$ROOT_DIR/files/config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"; then
    die "kitty config does not match repository version"
  fi

  if ! cmp -s "$ROOT_DIR/files/config/DankMaterialShell/settings.json" "$HOME/.config/DankMaterialShell/settings.json"; then
    die "DMS settings.json does not match repository version"
  fi

  for managed_config in \
    niri/dms/colors.kdl \
    niri/dms/keybinds.kdl \
    niri/dms/windowrules.kdl \
    niri/dms/input.kdl \
    kitty/dank-tabs.conf \
    kitty/dank-theme.conf
  do
    if ! cmp -s "$ROOT_DIR/files/config/$managed_config" "$HOME/.config/$managed_config"; then
      die "$managed_config does not match repository version"
    fi
  done

  if command -v jq >/dev/null 2>&1; then
    if [[ "$(jq -r '.matugenTemplateNiri' "$HOME/.config/DankMaterialShell/settings.json")" != "false" ]]; then
      die "DMS matugenTemplateNiri must be false"
    fi
    if [[ "$(jq -r '.matugenTemplateKitty' "$HOME/.config/DankMaterialShell/settings.json")" != "false" ]]; then
      die "DMS matugenTemplateKitty must be false"
    fi
    if [[ "$(jq -r '.fontFamily' "$HOME/.config/DankMaterialShell/settings.json")" != "Inter Variable" ]]; then
      die "DMS fontFamily must be Inter Variable"
    fi
  fi

  if command -v fc-match >/dev/null 2>&1; then
    dms_font_match="$(fc-match -f '%{family}\n' 'Inter Variable' 2>/dev/null | head -n 1 || true)"
    if [[ "$dms_font_match" != *Inter* ]]; then
      die "Inter Variable font is not available to fontconfig, got: ${dms_font_match:-none}"
    fi
  fi

  applications_dst="$HOME/.local/share/applications"

  if [[ ! -f "$applications_dst/nvim.desktop" ]]; then
    die "nvim.desktop missing: $applications_dst/nvim.desktop"
  fi

  for user_dir in Desktop Downloads Templates Public Documents Music Pictures Videos Projects; do
    if [[ ! -d "$HOME/$user_dir" ]]; then
      die "User directory missing: $HOME/$user_dir"
    fi
  done

  if command -v xdg-user-dir >/dev/null 2>&1; then
    if [[ "$(xdg-user-dir DESKTOP)" != "$HOME/Desktop" ]]; then
      die "XDG desktop directory is not $HOME/Desktop"
    fi
    if [[ "$(xdg-user-dir DOWNLOAD)" != "$HOME/Downloads" ]]; then
      die "XDG download directory is not $HOME/Downloads"
    fi
    if [[ "$(xdg-user-dir DOCUMENTS)" != "$HOME/Documents" ]]; then
      die "XDG documents directory is not $HOME/Documents"
    fi
  fi

  if command -v xdg-mime >/dev/null 2>&1; then
    text_default="$(xdg-mime query default text/plain 2>/dev/null || true)"
    dir_default="$(xdg-mime query default inode/directory 2>/dev/null || true)"
    if [[ "$text_default" != "nvim.desktop" ]]; then
      die "text/plain MIME default must be nvim.desktop, got: ${text_default:-none}"
    fi
    if [[ "$dir_default" != "org.gnome.Nautilus.desktop" ]]; then
      die "inode/directory MIME default must be org.gnome.Nautilus.desktop, got: ${dir_default:-none}"
    fi
  fi

  rime_default="$HOME/.local/share/fcitx5/rime/build/default.yaml"
  for rime_custom in \
    "$HOME/.config/fcitx5/rime/default.custom.yaml" \
    "$HOME/.local/share/fcitx5/rime/default.custom.yaml"; do
    if ! cmp -s "$ROOT_DIR/files/config/fcitx5/rime/default.custom.yaml" "$rime_custom"; then
      die "Rime default.custom.yaml does not match repository version: $rime_custom"
    fi
    if grep -Eq 'luna_pinyin|luna_pinyin_simp|luna_pinyin_fluency' "$rime_custom"; then
      die "Rime custom config still contains luna pinyin: $rime_custom"
    fi
  done

  if [[ -f "$rime_default" ]]; then
    mapfile -t rime_schemas < <(awk '$1 == "-" && $2 == "schema:" { print $3 }' "$rime_default")
    if [[ "${#rime_schemas[@]}" -ne 1 || "${rime_schemas[0]:-}" != "rime_ice" ]]; then
      die "Rime schema_list must be exactly rime_ice, got: ${rime_schemas[*]:-none}"
    fi
  else
    die "Rime build file missing: $rime_default"
  fi

  if [[ ! -f /usr/share/rime-data/wanxiang-lts-zh-hans.gram \
    && ! -f "$HOME/.local/share/fcitx5/rime/wanxiang-lts-zh-hans.gram" ]]; then
    die "Wanxiang grammar model missing: wanxiang-lts-zh-hans.gram"
  fi

  if [[ -f "$HOME/.local/share/fcitx5/rime/user.yaml" ]] \
    && ! grep -q 'previously_selected_schema:[[:space:]]*rime_ice' "$HOME/.local/share/fcitx5/rime/user.yaml"; then
    die "Rime active schema must be rime_ice"
  fi

  for stale_rime in \
    "$HOME/.config/fcitx5/rime/luna_pinyin.custom.yaml" \
    "$HOME/.config/fcitx5/rime/luna_pinyin_simp.custom.yaml" \
    "$HOME/.config/fcitx5/rime/luna_pinyin_fluency.custom.yaml" \
    "$HOME/.local/share/fcitx5/rime/luna_pinyin.custom.yaml" \
    "$HOME/.local/share/fcitx5/rime/luna_pinyin_simp.custom.yaml" \
    "$HOME/.local/share/fcitx5/rime/luna_pinyin_fluency.custom.yaml"; do
    if [[ -e "$stale_rime" || -L "$stale_rime" ]]; then
      die "Stale luna pinyin config remains: $stale_rime"
    fi
  done

  if command -v fish >/dev/null 2>&1; then
    fish_path="$(command -v fish)"
    current_shell="$(getent passwd "$USER" | cut -d: -f7)"
    if [[ "$current_shell" != "$fish_path" ]]; then
      die "Default shell must be $fish_path, got: $current_shell"
    fi
  fi

  if getent group input >/dev/null 2>&1 && ! id -nG "$USER" | tr " " "\n" | grep -Fxq input; then
    die "$USER is not in input group; log out and back in after usermod if this was just changed"
  fi

  if systemctl --user list-unit-files dsearch.service >/dev/null 2>&1; then
    if ! systemctl --user is-enabled --quiet dsearch.service; then
      die "dsearch.service is not enabled"
    fi
  fi

  if [[ "$SKIP_DMS" -ne 1 ]] && systemctl --user list-unit-files dms.service >/dev/null 2>&1; then
    if ! systemctl --user is-enabled --quiet dms.service; then
      die "dms.service is not enabled"
    fi
    if systemctl --user is-active --quiet dms.service; then
      die "dms.service should not be active during install validation; it must start after restored configs are in place"
    fi
  fi
fi
