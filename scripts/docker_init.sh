#!/usr/bin/env bash
# Docker 一键环境初始化：zsh(+oh-my-zsh) / neovim / tmux
# 并软链本仓库 env/ 与 init.vim 配置（等价于 env_init.sh + nvim 配置）
#
# 用法:
#   bash scripts/docker_init.sh
#
# 可选环境变量:
#   GITHUB_PROXY   GitHub 下载代理前缀, 如 https://gh-proxy.com/
#   USE_GITEE=1    oh-my-zsh 及 zsh 插件改用 gitee 镜像
#   NVIM_VERSION   锁定 neovim 版本, 如 v0.10.4 (默认 latest)
#   SKIP_PLUGINS=1 跳过 nvim 插件安装 (PlugInstall)
#   CLAUDE_VERSION 锁定 Claude Code CLI 版本, 如 v2.1.301 (默认 latest)
#   CLAUDE_FORCE=1 Claude CLI 已安装时强制重新下载

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVIM_VERSION="${NVIM_VERSION:-latest}"

log()  { printf '\033[1;32m[+]\033[0m %s\n' "$*"; }
info() { printf '\033[1;34m[i]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

# root 直接装系统，否则尝试 sudo
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
    else
        die "需要 root 权限安装软件包，请在 root 下运行或安装 sudo"
    fi
fi

gh_url() { printf '%s%s' "${GITHUB_PROXY:-}" "$1"; }

###############################################################################
# 1. 系统依赖
###############################################################################
install_packages() {
    log "通过系统包管理器安装 zsh / tmux / neovim 依赖"
    if command -v apt-get >/dev/null 2>&1; then
        $SUDO apt-get update
        DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -y --no-install-recommends \
            zsh tmux git curl ca-certificates tar gzip
    elif command -v dnf >/dev/null 2>&1; then
        $SUDO dnf install -y zsh tmux git curl tar gzip ca-certificates findutils
    elif command -v yum >/dev/null 2>&1; then
        $SUDO yum install -y zsh tmux git curl tar gzip ca-certificates findutils
    elif command -v apk >/dev/null 2>&1; then
        $SUDO apk add --no-cache zsh tmux git curl tar gzip ca-certificates bash procps
    else
        die "不支持的发行版（未找到 apt-get/dnf/yum/apk）"
    fi
}

###############################################################################
# 2. oh-my-zsh 及插件
###############################################################################
install_oh_my_zsh() {
    local zsh_dir="$HOME/.oh-my-zsh"
    local custom_dir="$zsh_dir/custom/plugins"

    if [ "${USE_GITEE:-0}" = "1" ]; then
        omz_repo="https://gitee.com/mirrors/oh-my-zsh.git"
        highlight_repo="https://gitee.com/mirrors/zsh-syntax-highlighting.git"
        suggest_repo="https://gitee.com/mirrors/zsh-autosuggestions.git"
    else
        omz_repo="$(gh_url https://github.com/ohmyzsh/ohmyzsh.git)"
        highlight_repo="$(gh_url https://github.com/zsh-users/zsh-syntax-highlighting.git)"
        suggest_repo="$(gh_url https://github.com/zsh-users/zsh-autosuggestions.git)"
    fi

    if [ ! -d "$zsh_dir" ]; then
        log "安装 oh-my-zsh"
        git clone --depth=1 "$omz_repo" "$zsh_dir"
    else
        info "oh-my-zsh 已存在，跳过"
    fi

    mkdir -p "$custom_dir"
    z_repo="$(gh_url https://github.com/agkozak/zsh-z.git)"
    for pair in \
        "zsh-syntax-highlighting:$highlight_repo" \
        "zsh-autosuggestions:$suggest_repo" \
        "zsh-z:$z_repo"; do
        name="${pair%%:*}"; repo="${pair#*:}"
        if [ ! -d "$custom_dir/$name" ]; then
            log "安装 zsh 插件 $name"
            git clone --depth=1 "$repo" "$custom_dir/$name"
        fi
    done
}

###############################################################################
# 3. neovim（官方稳定版 tarball）
###############################################################################
nvim_new_enough() {
    command -v nvim >/dev/null 2>&1 || return 1
    nvim --version | head -1 | awk '{
        split(substr($2, 2), v, /[.-]/)
        cur = v[1] * 1000 + v[2]
        exit !(cur >= 9)
    }'
}

install_neovim() {
    if nvim_new_enough; then
        info "nvim $(nvim --version | head -1) 已满足要求，跳过安装"
        return
    fi

    # Alpine(musl) 无法运行官方 glibc tarball，退回包管理器版本
    if command -v apk >/dev/null 2>&1; then
        warn "Alpine 使用 apk 安装 neovim（版本可能较旧）"
        $SUDO apk add --no-cache neovim
        return
    fi

    case "$(uname -m)" in
        x86_64)  arch="x86_64" ;;
        aarch64) arch="arm64" ;;
        *) die "不支持的架构: $(uname -m)" ;;
    esac

    # GitHub "最新版本资产" URL 是 releases/latest/download/...（自动重定向到最新 release）
    # 锁定版本时用 releases/download/<tag>/...；0.9.x 的资产名为 nvim-linux64.tar.gz
    local urls=()
    if [ "$NVIM_VERSION" = "latest" ]; then
        urls+=("https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$arch.tar.gz")
    else
        urls+=("https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux-$arch.tar.gz")
        [ "$arch" = "x86_64" ] && urls+=("https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux64.tar.gz")
    fi

    local tmp ok=""
    tmp="$(mktemp -t nvim.XXXXXX.tar.gz)"
    for raw_url in "${urls[@]}"; do
        log "下载 neovim ($NVIM_VERSION)"
        if curl -fL --retry 3 --connect-timeout 15 -o "$tmp" "$(gh_url "$raw_url")"; then
            ok=1
            break
        fi
        warn "下载失败: $raw_url"
    done
    [ -n "$ok" ] || die "neovim 下载失败，可用 GITHUB_PROXY=... 或 NVIM_VERSION=vX.Y.Z 指定镜像/版本"

    if [ "$(id -u)" -eq 0 ]; then
        log "安装 neovim 到 /usr/local"
        tar xzf "$tmp" -C /usr/local --strip-components=1
    else
        local opt_dir="$HOME/.local/opt/nvim"
        log "安装 neovim 到 \$HOME/.local"
        mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
        rm -rf "$opt_dir"
        mkdir -p "$opt_dir"
        tar xzf "$tmp" -C "$opt_dir" --strip-components=1
        ln -sfn "$opt_dir/bin/nvim" "$HOME/.local/bin/nvim"
        grep -q 'HOME/.local/bin' "$HOME/.env.zsh" 2>/dev/null || \
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.env.zsh"
        export PATH="$HOME/.local/bin:$PATH"
    fi
    rm -f "$tmp"
}

###############################################################################
# 4. 软链配置
###############################################################################
link_configs() {
    log "软链 env/ 与 nvim 配置（参考 env_init.sh）"
    ln -sfn "$REPO_DIR/env/.zshrc"           "$HOME/.zshrc"
    ln -sfn "$REPO_DIR/env/.tmux.conf"       "$HOME/.tmux.conf"
    ln -sfn "$REPO_DIR/env/.tmux.conf.local" "$HOME/.tmux.conf.local"
    ln -sfn "$REPO_DIR/env/.script.zsh"      "$HOME/.script.zsh"

    mkdir -p "$HOME/.config/nvim" "$HOME/.vim" "$HOME/.cache/undodir"
    ln -sfn "$REPO_DIR/init.vim" "$HOME/.config/nvim/init.vim"
}

###############################################################################
# 5. nvim 插件
###############################################################################
install_nvim_plugins() {
    if [ "${SKIP_PLUGINS:-0}" = "1" ]; then
        info "SKIP_PLUGINS=1，跳过插件安装（进入 nvim 后执行 :PlugInstall）"
        return
    fi
    log "安装 nvim 插件 (PlugInstall)"
    if ! nvim --headless +PlugInstall +qa; then
        warn "PlugInstall 执行失败，进入 nvim 后可手动执行 :PlugInstall"
    fi
}

###############################################################################
# 6. Claude Code CLI（GitHub release 原生二进制，不走 claude.ai 安装脚本）
#    GITHUB_PROXY 指定 GitHub 加速前缀，如 https://gh-proxy.com/
#    CLAUDE_VERSION 锁定版本（如 v2.1.301，默认 latest）
#    CLAUDE_FORCE=1 已安装时强制重新下载
###############################################################################
install_claude_cli() {
    if command -v claude >/dev/null 2>&1 && [ "${CLAUDE_FORCE:-0}" != "1" ]; then
        info "claude CLI 已存在: $(claude --version 2>/dev/null)，跳过（CLAUDE_FORCE=1 可重装）"
        return
    fi

    case "$(uname -m)" in
        x86_64)  arch="x64" ;;
        aarch64) arch="arm64" ;;
        *) die "不支持的架构: $(uname -m)" ;;
    esac
    # Alpine(musl) 用 musl 构建，其余发行版用 gnu 构建
    local libc=""
    if command -v apk >/dev/null 2>&1 || ldd --version 2>&1 | grep -qi musl; then
        libc="-musl"
    fi
    local asset="claude-linux-${arch}${libc}.tar.gz"

    local tag base
    tag="${CLAUDE_VERSION:-latest}"
    if [ "$tag" = "latest" ]; then
        base="https://github.com/anthropics/claude-code/releases/latest/download"
    else
        base="https://github.com/anthropics/claude-code/releases/download/$tag"
    fi

    local tmp sums want got
    tmp="$(mktemp -t claude.XXXXXX.tar.gz)"
    log "下载 Claude Code CLI ($tag/$asset)"
    if ! curl -fL --retry 3 --connect-timeout 15 -o "$tmp" "$(gh_url "$base/$asset")"; then
        rm -f "$tmp"
        die "claude 下载失败，可尝试 GITHUB_PROXY=https://gh-proxy.com/ bash scripts/docker_init.sh"
    fi

    # 官方 SHASUMS256 校验；校验文件拉不下来仅告警不阻断
    sums="$(mktemp -t claude-shasums.XXXXXX)"
    if curl -fsL --connect-timeout 15 -o "$sums" "$(gh_url "$base/SHASUMS256.txt")"; then
        want="$(awk -v a="$asset" '$2==a{print $1}' "$sums")"
        got="$(sha256sum "$tmp" | awk '{print $1}')"
        if [ -z "$want" ] || [ "$want" != "$got" ]; then
            rm -f "$tmp" "$sums"
            die "claude SHA256 校验失败（期望 $want，实际 $got），镜像内容可能被篡改"
        fi
    else
        warn "SHASUMS256.txt 拉取失败，跳过完整性校验"
    fi
    rm -f "$sums"

    if [ "$(id -u)" -eq 0 ]; then
        log "安装 claude 到 /usr/local/bin"
        tar xzf "$tmp" -C /usr/local/bin
        chmod +x /usr/local/bin/claude
    else
        local opt_dir="$HOME/.local/opt/claude"
        log "安装 claude 到 \$HOME/.local"
        mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
        rm -rf "$opt_dir"
        mkdir -p "$opt_dir"
        tar xzf "$tmp" -C "$opt_dir"
        chmod +x "$opt_dir/claude"
        ln -sfn "$opt_dir/claude" "$HOME/.local/bin/claude"
        grep -q 'HOME/.local/bin' "$HOME/.env.zsh" 2>/dev/null || \
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.env.zsh"
        export PATH="$HOME/.local/bin:$PATH"
    fi
    rm -f "$tmp"

    if ! command -v claude >/dev/null 2>&1; then
        die "claude 安装完成但不在 PATH 中，执行 export PATH=\"\$HOME/.local/bin:\$PATH\" 后重试"
    fi
    log "claude CLI: $(claude --version 2>&1)"
}

###############################################################################
# 7. VSCode Claude 插件：自动批准（bypassPermissions）
#    Machine 级设置，容器内所有 VSCode 窗口/新会话默认跳过权限确认
###############################################################################
config_vscode_claude() {
    local settings_dir="$HOME/.vscode-server/data/Machine"
    local settings_file="$settings_dir/settings.json"

    if [ -f "$settings_file" ] && grep -q '"claudeCode.initialPermissionMode"' "$settings_file"; then
        info "VSCode Claude 自动批准配置已存在，跳过"
        return
    fi

    log "写入 VSCode Claude 插件 Machine 设置（bypassPermissions）"
    mkdir -p "$settings_dir"
    if [ -f "$settings_file" ]; then
        warn "$settings_file 已存在但缺少相关配置，请手动合并:"
        printf '  "claudeCode.allowDangerouslySkipPermissions": true,\n  "claudeCode.initialPermissionMode": "bypassPermissions"\n'
        return
    fi
    cat > "$settings_file" <<'EOF'
{
  "claudeCode.allowDangerouslySkipPermissions": true,
  "claudeCode.initialPermissionMode": "bypassPermissions"
}
EOF
}

###############################################################################
# 8. 切换默认 shell（best effort）
###############################################################################
set_default_shell() {
    local zsh_bin
    zsh_bin="$(command -v zsh)"
    if [ "$(id -u)" -eq 0 ] && [ -w /etc/shells ] && ! grep -qx "$zsh_bin" /etc/shells; then
        echo "$zsh_bin" >> /etc/shells
    fi
    if command -v chsh >/dev/null 2>&1; then
        chsh -s "$zsh_bin" 2>/dev/null || warn "chsh 失败（容器内常见），可手动执行: exec zsh"
    fi
}

main() {
    install_packages
    install_oh_my_zsh
    install_neovim
    link_configs
    install_nvim_plugins
    install_claude_cli
    config_vscode_claude
    set_default_shell

    cat <<EOF

$(printf '\033[1;32m')安装完成\033[0m
  zsh 配置:  ~/.zshrc          -> $REPO_DIR/env/.zshrc
  tmux 配置: ~/.tmux.conf      -> $REPO_DIR/env/.tmux.conf
  nvim 配置: ~/.config/nvim/init.vim -> $REPO_DIR/init.vim
  claude:    $(command -v claude || echo '~/.local/bin/claude') ($(claude --version 2>/dev/null || echo 'Claude Code CLI'))
  VSCode:    ~/.vscode-server/data/Machine/settings.json (Claude 自动批准)

  立即生效: exec zsh
  安装插件: nvim +PlugInstall
EOF
}

main "$@"
