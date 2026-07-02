# pang-arch-vm-setup

这是我给 Arch Linux 虚拟机准备的一键桌面环境部署脚本。

它适合在“已经安装好并能进入系统的 Arch Linux”里运行，用来快速装好常用软件、桌面环境、输入法、终端、Neovim、个人脚本和常用配置。

## 主要内容

- 桌面环境：niri + DankMaterialShell
- 登录界面：SDDM + Pixie 主题
- 输入法：fcitx5 + 雾凇拼音
- 终端：kitty + fish + starship
- 编辑器：Neovim + Neovide
- 文件与媒体：Nautilus、Loupe、mpv、yazi
- OCR/PDF：tesseract、中文/英文识别数据、poppler
- 常用工具：git、paru、fzf、ripgrep、fd、eza、jq、glow
- 编程环境：base-devel、clang、Python/pip、Node.js/npm、Go、Rust/cargo、JDK
- 日常应用：Chrome、QQ、微信 AppImage、Obsidian
- 个人配置：nvim、fish、kitty、niri、DMS、opencode、脚本、壁纸、头像

这个仓库不负责 Arch 的分区、格式化、引导器安装，也不包含物理机专用驱动、电池优化、显卡特殊配置。

## 使用方法

一条命令安装：

```bash
curl -fsSL https://raw.githubusercontent.com/tjz123psh/pang-arch-vm-setup/main/bootstrap.sh | bash -s -- -y
```

如果想先手动克隆，也可以：

```bash
sudo pacman -S --needed git curl
git clone https://github.com/tjz123psh/pang-arch-vm-setup.git
cd pang-arch-vm-setup
./install.sh
```

如果想自动确认：

```bash
./install.sh -y
```

脚本会直接安装完整环境，包括 QQ、微信 AppImage、Chrome、Obsidian 等日常软件。

如果不想安装 DMS：

```bash
./install.sh --skip-dms
```

## 推荐流程

刚装好的 Arch 虚拟机里，推荐直接执行：

```bash
curl -fsSL https://raw.githubusercontent.com/tjz123psh/pang-arch-vm-setup/main/bootstrap.sh | bash -s -- -y
```

如果 `raw.githubusercontent.com` 暂时不可用，可以试 jsDelivr 备用入口：

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/tjz123psh/pang-arch-vm-setup@main/bootstrap.sh | bash -s -- -y
```

如果想使用持久仓库目录，可以手动克隆：

```bash
mkdir -p ~/projects
git clone https://github.com/tjz123psh/pang-arch-vm-setup.git ~/projects/pang-arch-vm-setup
cd ~/projects/pang-arch-vm-setup
./install.sh -y
```

## 注意

- 脚本会安装系统软件和 AUR 软件。
- 脚本会复制仓库里的配置到当前用户目录。
- 已存在的配置文件会先备份再覆盖。
- 私密数据、浏览器登录状态、聊天记录、API key 不会放进仓库。
- 这个项目主要面向虚拟机，不按物理机驱动方案设计。
- Rime 的系统默认数据里可能带有明月拼音，但本仓库部署后只启用雾凇拼音 `rime_ice`。
