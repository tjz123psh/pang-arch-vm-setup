#!/usr/bin/env bash

pictures_src="$ROOT_DIR/files/pictures"
if [[ -d "$pictures_src" ]]; then
  sync_dir_contents "$pictures_src" "$HOME/Pictures"
  if [[ -f "$pictures_src/头像/头像.png" ]]; then
    install_file_or_dir "$pictures_src/头像/头像.png" "$HOME/.face"
  fi
fi

sddm_theme_src="$ROOT_DIR/files/sddm/themes/pixie"
if [[ -d "$sddm_theme_src" ]]; then
  run_cmd sudo mkdir -p /usr/share/sddm/themes
  run_cmd sudo rm -rf /usr/share/sddm/themes/pixie
  run_cmd sudo cp -a "$sddm_theme_src" /usr/share/sddm/themes/pixie
  run_cmd sudo chmod -R a+rX /usr/share/sddm/themes/pixie

  if [[ -f "$ROOT_DIR/files/pictures/图像/【哲风壁纸】动漫-夜空-宇宙.png" ]]; then
    run_cmd sudo mkdir -p /usr/share/sddm/backgrounds
    run_cmd sudo cp -a "$ROOT_DIR/files/pictures/图像/【哲风壁纸】动漫-夜空-宇宙.png" /usr/share/sddm/backgrounds/zhfeng.png
    run_cmd sudo chmod a+r /usr/share/sddm/backgrounds/zhfeng.png
  fi

  run_cmd sudo mkdir -p /etc/sddm.conf.d
  run_shell 'printf "%s\n" "[Theme]" "Current=pixie" | sudo tee /etc/sddm.conf.d/10-pang-theme.conf >/dev/null'
fi
