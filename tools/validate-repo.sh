#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

find . -type f \( -name '*.sh' -o -path './install.sh' \) -print | sort | xargs -r bash -n
find . -type f \( -name '*.sh' -o -path './install.sh' \) -print | sort | xargs -r shellcheck -x

./install.sh --dry-run --skip-dms -y >/dev/null

if [[ -e files/config/opencode/opencode.json ]]; then
  echo "Forbidden file present: files/config/opencode/opencode.json" >&2
  exit 1
fi

if [[ -e files/config/fish/secrets.fish ]]; then
  echo "Forbidden file present: files/config/fish/secrets.fish" >&2
  exit 1
fi

if find files -path '*/.git' -type d -print -quit | grep -q .; then
  echo "Nested .git directory found under files/" >&2
  exit 1
fi

if grep -RInE '(sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{40,}|-----BEGIN (RSA |OPENSSH |EC |DSA )?PRIVATE KEY-----)' files 2>/dev/null; then
  echo "High-confidence secret pattern found under files/" >&2
  exit 1
fi

echo "repo validation ok"
