# 新 Arch 虚拟机安装流程

这份文档从“Arch Linux 已经安装完成，并且可以正常进入系统”开始。

本仓库不负责磁盘分区、Btrfs 布局、引导器安装，也不处理物理机硬件驱动。它适合已经联网、已经有普通 sudo 用户的 Arch 虚拟机。

## 1. 推荐一条命令安装

在刚装好的 Arch 虚拟机里，用普通用户执行：

```bash
curl -fsSL https://raw.githubusercontent.com/tjz123psh/pang-arch-vm-setup/main/bootstrap.sh | bash -s -- -y
```

如果 `raw.githubusercontent.com` 暂时不可用，可以试 jsDelivr 备用入口：

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/tjz123psh/pang-arch-vm-setup@main/bootstrap.sh | bash -s -- -y
```

如果想保留持久仓库目录，则执行：

```bash
mkdir -p ~/projects
git clone https://github.com/tjz123psh/pang-arch-vm-setup.git ~/projects/pang-arch-vm-setup
cd ~/projects/pang-arch-vm-setup
./install.sh -y
```

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

当前默认会安装完整个人 VM 环境，包括 Google Chrome、QQ、微信 AppImage、Obsidian、Neovide、OCR/PDF 工具和个人脚本。

开发/编程环境默认包含 `base-devel`、`clang`、`python`、`python-pip`、`nodejs`、`npm`、`go`、`rust` 和 `jdk-openjdk`。这里使用 Arch 官方仓库的 `rust` 包，它同时提供 `cargo` 和 `rustfmt`。安装脚本会把官方包列表里的项目标记为显式安装，避免 Rust 这类工具链因为曾经只是 AUR 构建依赖而变成孤儿包。仓库不默认使用 `rustup`，避免额外引入用户目录里的 toolchain 状态。

如果根分区是 Btrfs，安装脚本会自动创建 Snapper `root` 配置，设置 `wheel` 组可用并开启 ACL 同步。如果 `/home` 是独立 Btrfs 挂载点，也会创建 `home` 配置；如果 `/home` 只是根子卷内的普通目录，则由 `root` 配置覆盖。这样 `sysup` 在调用 `paru` 更新前可以先创建快照。

## 4. DMS 说明

脚本通过 Arch 官方仓库包安装 DMS：`dms-shell-niri` 会拉入 DMS 本体、quickshell、dgop、accountsservice 和 niri 相关依赖。这里不再运行官方 `dankinstall` TUI，避免交互界面卡住、跳过终端选择或无法输入密码时隐藏真实问题。

DMS 官方安装器会生成默认 niri/kitty/font 配置；本仓库改为直接部署自己的 DMS settings、niri 和 kitty 配置。脚本安装 DMS 包后保持 `dms.service` 停止，随后恢复仓库配置；如果当前已经在图形会话中，脚本会立即启动 DMS，否则它会在下一次图形登录时启动。

脚本仍会安装 DMS 常用可选依赖：`matugen`、`cava`、`power-profiles-daemon`、`qt6-multimedia`、`qt6ct`、`wtype`、`cups-pk-helper`、`kimageformats`。默认安装最后会校验 `dms` 命令是否存在；如果只想先部署基础环境，可以使用 `./install.sh --skip-dms -y`。

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

快照状态：

```bash
snapper list-configs
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
- 微信使用 `wechat-appimage`，对齐当前主系统；不默认安装 `wechat-universal-bwrap` 沙箱版。如果旧 VM 里已经装过 bwrap 版本，安装脚本会先移除旧包再安装 AppImage 版本。
- `paru-ui` 首次构建完整 AUR 索引需要网络访问；如果刷新失败，会回退到已有缓存。
