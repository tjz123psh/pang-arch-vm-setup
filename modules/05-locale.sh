#!/usr/bin/env bash

ensure_locale_line() {
  local name="$1"
  local charset="$2"
  local name_re="${name//./\\.}"

  if grep -Eq "^[[:space:]]*${name_re}[[:space:]]+${charset}[[:space:]]*$" /etc/locale.gen; then
    return 1
  fi

  if grep -Eq "^[[:space:]]*#[[:space:]]*${name_re}[[:space:]]+${charset}[[:space:]]*$" /etc/locale.gen; then
    run_cmd sudo sed -i -E "s|^[[:space:]]*#[[:space:]]*(${name_re}[[:space:]]+${charset})[[:space:]]*$|\\1|" /etc/locale.gen
    return 0
  fi

  warn "Locale entry not found in /etc/locale.gen: $name $charset"
  return 1
}

changed=0
ensure_locale_line "en_US.UTF-8" "UTF-8" && changed=1
ensure_locale_line "zh_CN.UTF-8" "UTF-8" && changed=1

if [[ "$changed" -eq 1 ]] || ! locale -a | grep -Fqx "zh_CN.utf8"; then
  run_cmd sudo locale-gen
else
  log "Locales already generated"
fi
