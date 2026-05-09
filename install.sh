#!/bin/bash
# =============================================================================
# install.sh — Install base packages across platforms
#   macOS / Debian / RHEL / Arch / Alpine / WSL2
#
#   Two-tier install:
#     - core packages: must succeed (set -e aborts on failure)
#     - optional packages: best-effort, failures collected and reported at the end
# =============================================================================
set -e

_OS="$(uname)"
MISSING_PKGS=()

# Best-effort install: try each package, record failures, never abort.
try_install() {
    local installer="$1"; shift
    local pkg
    for pkg in "$@"; do
        if ! eval "$installer $pkg" >/dev/null 2>&1; then
            MISSING_PKGS+=("$pkg")
        fi
    done
}

report_missing() {
    if [[ ${#MISSING_PKGS[@]} -gt 0 ]]; then
        echo ""
        echo "==> Optional packages that did not install (install manually if needed):"
        printf '   - %s\n' "${MISSING_PKGS[@]}"
    else
        echo ""
        echo "==> All optional packages installed."
    fi
}

# Upstream installers for tools commonly missing from distro repos.
install_starship_upstream() {
    if command -v starship &>/dev/null; then return 0; fi
    echo "==> Installing starship via upstream script..."
    mkdir -p "$HOME/.local/bin"
    if ! curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin" >/dev/null 2>&1; then
        MISSING_PKGS+=("starship")
    fi
}

install_yazi_upstream() {
    if command -v yazi &>/dev/null; then return 0; fi
    if command -v cargo &>/dev/null; then
        echo "==> Installing yazi via cargo..."
        if ! cargo install --locked yazi-fm yazi-cli >/dev/null 2>&1; then
            MISSING_PKGS+=("yazi")
        fi
    else
        MISSING_PKGS+=("yazi (no cargo available)")
    fi
}

install_bun_upstream() {
    if command -v bun &>/dev/null; then return 0; fi
    echo "==> Installing bun via upstream script..."
    if ! curl -fsSL https://bun.sh/install | bash >/dev/null 2>&1; then
        MISSING_PKGS+=("bun")
    fi
}

# ---- macOS (Homebrew) ----
if [[ "$_OS" == "Darwin" ]]; then
    # Apple Silicon: brew installs to /opt/homebrew/bin but is not in PATH by default
    if ! command -v brew &>/dev/null && [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Install it first:"
        echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        exit 1
    fi
    echo "==> macOS detected — installing from Brewfile"

    DOTDIR_LOCAL="$(cd "$(dirname "$0")" && pwd)"
    if [[ -f "$DOTDIR_LOCAL/Brewfile" ]]; then
        # brew bundle reports failures at the end and continues; no need for try_install here
        brew bundle install --file="$DOTDIR_LOCAL/Brewfile"
    else
        echo "Brewfile not found at $DOTDIR_LOCAL/Brewfile — falling back to minimal package list"
        brew install tmux zsh fzf curl git neovim
        try_install "brew install" lsd bat fastfetch zoxide starship fd gh yazi
    fi

    # bun is installed via upstream (not tracked in Brewfile) for parity with Linux paths
    install_bun_upstream
    report_missing
    exit 0
fi

# ---- Linux: detect package manager ----
if command -v apt &>/dev/null; then
    echo "==> Debian/Ubuntu-based (apt)"
    sudo apt update
    # Core
    sudo apt install -y tmux zsh fzf curl git vim neovim
    # Optional — note: apt provides fd-find (binary: fdfind) and bat (binary: batcat on older systems)
    try_install "sudo apt install -y" bat fd-find lsd zoxide direnv python3 python3-pip g++ nodejs golang-go rustc cargo php git-lfs gh fastfetch
    install_starship_upstream
    install_yazi_upstream
    install_bun_upstream
    report_missing
    exit 0
fi

if command -v dnf &>/dev/null; then
    echo "==> Fedora/RHEL-based (dnf)"
    sudo dnf install -y tmux zsh fzf curl git vim neovim
    try_install "sudo dnf install -y" bat fd-find lsd zoxide direnv python3 python3-pip gcc-c++ nodejs golang rust cargo php git-lfs gh fastfetch starship yazi
    install_starship_upstream
    install_yazi_upstream
    install_bun_upstream
    report_missing
    exit 0
fi

if command -v yum &>/dev/null; then
    echo "==> RHEL-based (yum)"
    sudo yum install -y tmux zsh fzf curl git vim
    try_install "sudo yum install -y" neovim bat fd-find zoxide direnv python3 gcc-c++ nodejs golang rust cargo php git-lfs gh
    install_starship_upstream
    install_yazi_upstream
    install_bun_upstream
    report_missing
    exit 0
fi

if command -v pacman &>/dev/null; then
    echo "==> Arch-based (pacman)"
    sudo pacman -Syu --noconfirm tmux zsh fzf curl git vim neovim
    try_install "sudo pacman -S --noconfirm" lsd bat fastfetch zoxide direnv broot fd python python-pip gcc nodejs go rust php git-lfs github-cli yazi starship
    install_bun_upstream
    report_missing
    exit 0
fi

if command -v apk &>/dev/null; then
    echo "==> Alpine-based (apk)"
    sudo apk update
    sudo apk add --no-cache tmux zsh fzf curl git vim neovim
    try_install "sudo apk add --no-cache" lsd bat fastfetch zoxide direnv fd python3 py3-pip g++ nodejs go rust cargo php git-lfs github-cli starship
    install_yazi_upstream
    install_bun_upstream
    report_missing
    exit 0
fi

echo "Unknown package manager. Install manually: tmux, zsh, fzf, curl, git, vim, neovim"
exit 1
