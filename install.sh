#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

DRY_RUN=0
YES=0
SKIP_DMS=0
WITH_APPS=0
PROFILE="vm"

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --dry-run      Print actions without changing the system
  -y, --yes      Do not ask for final confirmation
  --skip-dms     Skip DankMaterialShell installer
  --with-apps    Install optional daily desktop apps
  --profile VM   Profile name, default: vm
  -h, --help     Show help
EOF
}

while (($#)); do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    -y | --yes)
      YES=1
      ;;
    --skip-dms)
      SKIP_DMS=1
      ;;
    --with-apps)
      WITH_APPS=1
      ;;
    --profile)
      shift
      PROFILE="${1:?missing profile name}"
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

export ROOT_DIR DRY_RUN YES SKIP_DMS WITH_APPS PROFILE

# shellcheck disable=SC1091
source "$ROOT_DIR/lib/common.sh"

main() {
  log "Starting pang-arch-vm-setup profile=$PROFILE dry_run=$DRY_RUN skip_dms=$SKIP_DMS with_apps=$WITH_APPS"

  if [[ "$YES" -ne 1 && "$DRY_RUN" -ne 1 ]]; then
    confirm "This will install packages and copy selected dotfiles. Continue?"
  fi

  run_module "00-preflight.sh"
  run_module "05-locale.sh"
  run_module "10-packages.sh"
  run_module "20-dms.sh"
  run_module "30-dotfiles.sh"
  run_module "40-scripts.sh"
  run_module "45-assets.sh"
  run_module "50-services.sh"
  run_module "60-user-defaults.sh"
  run_module "90-validate.sh"

  log "Done"
}

main "$@"
