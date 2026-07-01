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
