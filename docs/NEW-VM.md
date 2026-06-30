# New Arch VM Setup

This guide starts after Arch Linux is already installed and bootable.

The installer does not partition disks, create Btrfs layouts, install a bootloader, or configure physical hardware drivers. Use it for a VM that already has network access and a normal user with sudo privileges.

## 1. Base Requirements

On the fresh VM, log in as the normal user, then install the minimum tools:

```bash
sudo pacman -Syu --needed git curl sudo base-devel
```

Confirm sudo works:

```bash
sudo -v
```

## 2. Clone

```bash
git clone https://github.com/tjz123psh/pang-arch-vm-setup.git
cd pang-arch-vm-setup
```

If SSH is already configured:

```bash
git clone git@github.com:tjz123psh/pang-arch-vm-setup.git
cd pang-arch-vm-setup
```

## 3. Inspect First

Always run a dry-run before changing the VM:

```bash
./install.sh --dry-run --skip-dms -y
```

Run repository validation:

```bash
tools/validate-repo.sh
```

## 4. Install

Without DMS first:

```bash
./install.sh --skip-dms
```

With DMS:

```bash
./install.sh
```

The DMS step runs the upstream installer:

```bash
curl -fsSL https://install.danklinux.com | sh
```

Use `--skip-dms` while testing base package and dotfile installation.

## 5. Private Files

Private files are intentionally not committed. Create them manually after the installer copies the public config.

### fish secrets

```bash
mkdir -p ~/.config/fish
cp templates/fish/secrets.fish.example ~/.config/fish/secrets.fish
chmod 600 ~/.config/fish/secrets.fish
nvim ~/.config/fish/secrets.fish
```

### opencode config

```bash
mkdir -p ~/.config/opencode
cp templates/opencode/opencode.json.example ~/.config/opencode/opencode.json
chmod 600 ~/.config/opencode/opencode.json
nvim ~/.config/opencode/opencode.json
```

Fill only the providers and API keys you actually use.

## 6. After Install

Check core commands:

```bash
fish -n ~/.config/fish/config.fish
nvim --headless '+lua print("nvim ok")' +qa
niri validate -c ~/.config/niri/config.kdl
opencode debug config >/dev/null
find ~/scripts -type f -perm -111 -print | sort | xargs -r bash -n
```

Check user services:

```bash
systemctl --user status dms.service dsearch.service --no-pager
systemctl --user status app-org.fcitx.Fcitx5@autostart.service --no-pager
systemctl --user status app-FlClash@autostart.service --no-pager
```

## 7. Updating This Repo From The Main Machine

On the main machine:

```bash
tools/sync-from-current-system.sh --dry-run
tools/sync-from-current-system.sh
tools/validate-repo.sh
git status
git add .
git commit -m "Update synced config"
git push
```

Before committing, verify these files are still absent:

```bash
test ! -e files/config/opencode/opencode.json
test ! -e files/config/fish/secrets.fish
find files -path '*/.git' -type d -print
```

## 8. Known Boundaries

- `opencode.json` is private and must be created manually.
- `fish/secrets.fish` is private and must be created manually.
- Browser profiles, proxy profiles, sync databases, and app caches are not part of this repo.
- Physical hardware setup is not part of this repo.
