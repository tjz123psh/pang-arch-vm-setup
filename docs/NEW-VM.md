# 新 Arch 虚拟机安装流程

这份文档从“Arch Linux 已经安装完成，并且可以正常进入系统”开始。

本仓库不负责磁盘分区、Btrfs 布局、引导器安装，也不处理物理机硬件驱动。它适合已经联网、已经有普通 sudo 用户的 Arch 虚拟机。

## 1. 推荐一条命令安装

在刚装好的 Arch 虚拟机里，用普通用户执行：

```bash
curl -fsSL https://raw.githubusercontent.com/tjz123psh/pang-arch-vm-setup/main/bootstrap.sh | bash -s -- -y
```

这个入口会自动安装基础工具、克隆仓库、更新仓库，然后执行 `./install.sh -y`。

## 2. 手动克隆方式

如果想先看仓库内容，也可以手动克隆：

```bash
sudo pacman -Syu --needed git curl sudo base-devel
git clone https://github.com/tjz123psh/pang-arch-vm-setup.git
cd pang-arch-vm-setup
./install.sh -y
```

如果 SSH 已经配置好：

```bash
git clone git@github.com:tjz123psh/pang-arch-vm-setup.git
cd pang-arch-vm-setup
./install.sh -y
```

## 3. 常用参数

只预览，不实际修改：

```bash
./install.sh --dry-run -y
```

跳过 DMS：

```bash
./install.sh --skip-dms -y
```

当前默认会安装完整个人 VM 环境，包括 Google Chrome、QQ、微信、Obsidian、Neovide、OCR/PDF 工具和个人脚本。

## 4. DMS 说明

脚本只有在系统里没有 `dms` 命令时，才会运行上游安装器：

```bash
curl -fsSL https://install.danklinux.com | sh
```

安装后会额外确保 `dms-shell-niri` 存在，避免 DMS 和 niri 集成缺依赖。

## 5. 私密文件

私密文件不进入仓库，需要安装完成后手动创建。

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

只填写实际要用的 provider 和 API key。

## 6. 安装后检查

核心检查命令：

```bash
fish -n ~/.config/fish/config.fish
nvim --headless '+lua print("nvim ok")' +qa
niri validate -c ~/.config/niri/config.kdl
opencode debug config >/dev/null
find ~/scripts -type f -perm -111 -print | sort | xargs -r bash -n
```

服务状态：

```bash
systemctl --user status dms.service dsearch.service --no-pager
systemctl --user status app-org.fcitx.Fcitx5@autostart.service --no-pager
systemctl --user status app-FlClash@autostart.service --no-pager
```

## 7. 从主系统同步配置到仓库

在主系统里：

```bash
cd ~/projects/pang-arch-vm-setup
tools/sync-from-current-system.sh --dry-run
tools/sync-from-current-system.sh
tools/validate-repo.sh
git status
git add .
git commit -m "Update synced config"
git push
```

提交前确认这些私密文件没有进入仓库：

```bash
test ! -e files/config/opencode/opencode.json
test ! -e files/config/fish/secrets.fish
find files -path '*/.git' -type d -print
```

## 8. 已知边界

- `opencode.json` 是私密文件，需要手动创建。
- `fish/secrets.fish` 是私密文件，需要手动创建。
- 浏览器配置、代理配置、同步数据库、聊天记录和缓存不进入仓库。
- 物理机驱动、电源管理、引导器和分区不属于这个仓库的范围。
- DMS 目前没有完整中文界面，这是上游限制。
- Wayland 下微信 bwrap 版本从 Nautilus 粘贴文件时，可能粘贴成路径；传文件优先用微信自己的文件选择器。
- `paru-ui` 首次构建完整 AUR 索引需要网络访问；如果刷新失败，会回退到已有缓存。
