#!/bin/bash
# =============================================================================
# install.sh — Install base packages across platforms
#   macOS / Debian / RHEL / Arch / Alpine / WSL2
# =============================================================================
set -e

_OS="$(uname)"

# ---- macOS (Homebrew) ----
if [[ "$_OS" == "Darwin" ]]; then
    echo "==> macOS detected — using Homebrew"
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Install it first:"
        echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        exit 1
    fi
    brew install tmux neovim zsh fzf curl gh lsd yazi bat neofetch git zoxide starship fd python3 gcc node go rust php git-lfs direnv broot bun
    exit 0
fi

# ---- Linux: detect package manager ----
if command -v apt &>/dev/null; then
    echo "==> Debian/Ubuntu-based (apt)"
    sudo apt update
    sudo apt install -y tmux vim zsh fzf curl yazi bat neofetch git zoxide starship fd-find python3 python3-pip g++ nodejs golang-go rustc cargo php git-lfs direnv broot
    exit 0
fi

if command -v dnf &>/dev/null; then
    echo "==> Fedora/RHEL-based (dnf)"
    sudo dnf install -y tmux vim zsh fzf curl yazi bat neofetch git zoxide starship fd-find python3 python3-pip gcc-c++ nodejs golang rust cargo php git-lfs direnv
    exit 0
fi

if command -v yum &>/dev/null; then
    echo "==> RHEL-based (yum)"
    sudo yum update
    sudo yum install -y tmux vim zsh fzf curl bat neofetch git zoxide fd-find python3 gcc-c++ nodejs golang rust cargo php git-lfs direnv
    exit 0
fi

if command -v pacman &>/dev/null; then
    echo "==> Arch-based (pacman)"
    sudo pacman -Syu --noconfirm tmux vim zsh fzf curl yazi bat neofetch git zoxide starship fd python python-pip gcc nodejs go rust php git-lfs direnv broot
    exit 0
fi

if command -v apk &>/dev/null; then
    echo "==> Alpine-based (apk)"
    sudo apk update
    sudo apk add --no-cache tmux vim zsh fzf curl bat neofetch git zoxide starship fd python3 py3-pip g++ nodejs go rust cargo php git-lfs direnv
    exit 0
fi

echo "Unknown package manager. Install manually: tmux, vim, zsh, fzf, curl"
exit 1
