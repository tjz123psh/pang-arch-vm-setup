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
  rime_default="$HOME/.local/share/fcitx5/rime/build/default.yaml"
  if [[ -f "$rime_default" ]]; then
    mapfile -t rime_schemas < <(awk '$1 == "-" && $2 == "schema:" { print $3 }' "$rime_default")
    if [[ "${#rime_schemas[@]}" -ne 1 || "${rime_schemas[0]:-}" != "rime_ice" ]]; then
      die "Rime schema_list must be exactly rime_ice, got: ${rime_schemas[*]:-none}"
    fi
  else
    die "Rime build file missing: $rime_default"
  fi
fi
