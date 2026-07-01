# pang-arch-vm-setup

Arch Linux VM post-install bootstrap for Pang's current desktop workflow.

This project is intentionally conservative: it assumes Arch Linux is already installed and bootable, then installs common desktop/system tools, copies a curated dotfile subset, installs personal scripts, optionally runs the DMS installer, enables user services, and validates the result.

## Scope

Included:

- VM-friendly desktop stack: niri, DMS, kitty, mako, fish, starship.
- Input method: fcitx5 + rime.
- Editor and tools: Neovim, Neovide, yazi, mpv, git, rg/fd/fzf/eza/jq.
- File basics: Nautilus, Loupe, XDG MIME defaults.
- Personal scripts and selected config files.

Excluded:

- Physical machine drivers, GPU-specific setup, battery/power tuning.
- Browser/app caches and private app state.
- Secrets, API keys, tokens, browser profiles, sync databases.
- Disk partitioning and Btrfs layout creation.
- Daily binary apps unless `--with-apps` is used.

## Usage

For a fresh VM, follow [docs/NEW-VM.md](docs/NEW-VM.md).

First sync the curated files from the current system:

```bash
tools/sync-from-current-system.sh --dry-run
tools/sync-from-current-system.sh
```

Dry-run first:

```bash
./install.sh --dry-run
```

Run:

```bash
./install.sh
```

Run with optional daily apps:

```bash
./install.sh --with-apps
```

Run without DMS:

```bash
./install.sh --skip-dms
```

## Design

The installer is split into modules under `modules/`:

| Module | Purpose |
| --- | --- |
| `00-preflight.sh` | Check OS, network, sudo, and required commands |
| `10-packages.sh` | Install official repo and AUR package lists |
| `20-dms.sh` | Optionally run the upstream DMS installer |
| `30-dotfiles.sh` | Copy curated files from `files/config/` into `~/.config/` |
| `40-scripts.sh` | Install personal scripts and symlink command entries |
| `50-services.sh` | Enable common user services when present |
| `90-validate.sh` | Run smoke checks |

## Safety

- `--dry-run` prints actions without changing the system.
- `--with-apps` installs optional AUR apps such as Chrome, QQ, WeChat, and Obsidian.
- Existing config paths are backed up before overwrite.
- Secrets are excluded by `.gitignore`.
- `tools/sync-from-current-system.sh` only copies paths listed in `config/dotfiles-manifest.txt`.
- Destructive cleanup is not part of this installer.

## Validation

Run before committing:

```bash
tools/validate-repo.sh
```
