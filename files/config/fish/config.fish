# 私有环境变量（从独立文件加载，不提交版本控制）
if test -f "$HOME/.config/fish/secrets.fish"
    source "$HOME/.config/fish/secrets.fish"
end

# 用户自定义脚本路径
fish_add_path -g ~/.local/bin ~/scripts/package ~/scripts/maintenance ~/scripts/desktop ~/scripts/media

if status is-interactive
# Commands to run in interactive sessions can go here
set fish_greeting ""
starship init fish | source

# 树形目录查看（需安装 eza）
function lt
    command eza --icons --tree $argv
end
end
