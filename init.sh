#!/bin/bash
# =============================================================================
# init.sh — Symlink dotfiles and set up zsh environment
#   Run this from within the dotfiles repo directory.
# =============================================================================
set -e

_OS="$(uname)"
DOTDIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Platform: $_OS"
echo "==> Dotfiles repo: $DOTDIR"

# ---- 1. Change default shell to zsh ----
if [[ "$SHELL" != *zsh* ]]; then
    echo "==> Changing default shell to zsh..."
    ZSH_PATH="$(which zsh)"
    if ! grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi
    chsh -s "$ZSH_PATH"
fi

# ---- 1b. macOS Apple Silicon: persist brew shellenv for future shells ----
# install.sh handles its own session via shellenv. Future zsh/bash shells need
# this in ~/.zprofile so /opt/homebrew/bin is on PATH from login.
if [[ "$_OS" == "Darwin" ]] && [[ -x /opt/homebrew/bin/brew ]]; then
    if ! grep -q "/opt/homebrew/bin/brew shellenv" "$HOME/.zprofile" 2>/dev/null; then
        {
            echo ''
            echo '# Homebrew (Apple Silicon)'
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
        } >> "$HOME/.zprofile"
        echo "==> Added Homebrew shellenv to ~/.zprofile"
    fi
fi

# ---- 2. Install Oh My Zsh ----
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "==> Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ---- 3. Install zsh plugins ----
echo "==> Installing zsh plugins..."
[[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] || \
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

[[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] || \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# ---- 5. Create symlinks ----
echo "==> Creating symlinks..."
symlink() {
    local src="$DOTDIR/$1"
    local dst="$HOME/$1"
    if [[ -L "$dst" ]]; then
        rm "$dst"
    elif [[ -f "$dst" ]]; then
        echo "   Backing up existing $dst → ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    ln -sf "$src" "$dst"
    echo "   Linked $dst → $src"
}

symlink ".zshrc"
symlink ".bashrc"
symlink ".vimrc"
symlink ".gitconfig"

# ---- 6. Set up per-machine .gitconfig.local ----
if [[ ! -f "$HOME/.gitconfig.local" ]]; then
    echo "==> Creating ~/.gitconfig.local (per-machine git settings)..."
    # Detect gh CLI path
    GH_PATH="$(command -v gh 2>/dev/null || true)"
    if [[ -n "$GH_PATH" ]]; then
        cat > "$HOME/.gitconfig.local" <<GITEOF
[credential "https://github.com"]
	helper =
	helper = !$GH_PATH auth git-credential
[credential "https://gist.github.com"]
	helper =
	helper = !$GH_PATH auth git-credential
GITEOF
        echo "   gh found at $GH_PATH — credential helpers configured"
    else
        cat > "$HOME/.gitconfig.local" <<'GITEOF'
# Add machine-specific git settings here.
# Example — GitHub CLI credential helper:
# [credential "https://github.com"]
#     helper = !/path/to/gh auth git-credential
GITEOF
        echo "   gh not found — add credential helpers to ~/.gitconfig.local manually if needed"
    fi
fi

# ---- 7. Install Oh My Tmux ----
OH_MY_TMUX_DIR="$HOME/.local/share/tmux/oh-my-tmux"
if [[ ! -d "$OH_MY_TMUX_DIR" ]]; then
    echo "==> Installing Oh My Tmux..."
    git clone --single-branch https://github.com/gpakosz/.tmux.git "$OH_MY_TMUX_DIR"
fi

# ---- 8. Set up ~/.config symlinks ----
echo "==> Creating ~/.config symlinks..."
config_symlink() {
    local src="$DOTDIR/config/$1"
    local dst="$HOME/.config/$1"
    mkdir -p "$(dirname "$dst")"
    if [[ -L "$dst" ]]; then
        rm "$dst"
    elif [[ -d "$dst" ]]; then
        echo "   Backing up existing dir $dst → ${dst}.bak"
        mv "$dst" "${dst}.bak"
    elif [[ -f "$dst" ]]; then
        echo "   Backing up existing $dst → ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    ln -sf "$src" "$dst"
    echo "   Linked $dst → $src"
}

mkdir -p "$HOME/.config/tmux"
ln -sf "$OH_MY_TMUX_DIR/.tmux.conf" "$HOME/.config/tmux/tmux.conf"
echo "   Linked $HOME/.config/tmux/tmux.conf → $OH_MY_TMUX_DIR/.tmux.conf"

config_symlink "git/ignore"
config_symlink "tmux/tmux.conf.local"
config_symlink "yazi"
config_symlink "nvim"
config_symlink "starship.toml"
config_symlink "bat/config"
config_symlink "fastfetch/config.jsonc"

# Ghostty is a macOS GUI terminal — skip on Linux/WSL2 servers where it's never installed.
if [[ "$_OS" == "Darwin" ]]; then
    config_symlink "ghostty"
fi

# Clean up stale ~/.config/neofetch symlink (config moved to fastfetch).
if [[ -L "$HOME/.config/neofetch/config.conf" ]] && [[ ! -e "$HOME/.config/neofetch/config.conf" ]]; then
    rm "$HOME/.config/neofetch/config.conf"
    rmdir "$HOME/.config/neofetch" 2>/dev/null || true
    echo "   Removed stale ~/.config/neofetch symlink"
fi

# ---- 9. Bootstrap / symlink Claude Code config (~/.claude/) ----
# Two modes:
#   claude_bootstrap = one-shot copy, never overwritten — for files that mix
#                      machine-local state with shared template (settings.json,
#                      statusline-command.sh, themes/).
#   claude_symlink   = symlink, dotfiles is source of truth — for pure display
#                      preferences that should sync across machines instantly.
echo "==> Bootstrapping Claude Code config..."
claude_bootstrap() {
    local rel="$1"
    local src="$DOTDIR/config/claude/$rel"
    local dst="$HOME/.claude/$rel"
    if [[ ! -e "$src" ]]; then
        return
    fi
    if [[ -e "$dst" ]]; then
        echo "   Skipped (exists): ~/.claude/$rel"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    cp -R "$src" "$dst"
    echo "   Copied ~/.claude/$rel"
}

claude_symlink() {
    local rel="$1"
    local src="$DOTDIR/config/claude/$rel"
    local dst="$HOME/.claude/$rel"
    if [[ ! -e "$src" ]]; then
        return
    fi
    mkdir -p "$(dirname "$dst")"
    if [[ -L "$dst" ]]; then
        rm "$dst"
    elif [[ -e "$dst" ]]; then
        echo "   Backing up existing $dst → ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    ln -sf "$src" "$dst"
    echo "   Linked ~/.claude/$rel → $src"
}

mkdir -p "$HOME/.claude"
claude_bootstrap "settings.json"
claude_bootstrap "statusline-command.sh"
claude_bootstrap "themes"
claude_symlink "CLAUDE.md"
claude_symlink "plugins/claude-hud/config.json"

# ---- 10. Create .zshrc.local / .bashrc.local templates if missing ----
if [[ ! -s "$HOME/.zshrc.local" ]]; then
    # -s: file exists AND has size > 0. Treat empty file the same as missing,
    # since empty files were created by a prior `touch ~/.zshrc.local`.
    cat > "$HOME/.zshrc.local" <<'ZLOCAL'
# Per-machine zsh overrides — not synced to the dotfiles repo.
# Use this file for absolute paths, private aliases, and host-specific env.
#
# Examples (uncomment and adjust paths if applicable on this machine):
# alias mysql=/usr/local/mysql-8.4.8-macos15-arm64/bin/mysql
# export M2_HOME=/usr/local/apache-maven-3.9.9
# [[ -d "$M2_HOME" ]] && export PATH="$PATH:$M2_HOME/bin"
ZLOCAL
    echo "   Wrote template to ~/.zshrc.local"
fi
[[ -f "$HOME/.bashrc.local" ]] || touch "$HOME/.bashrc.local"

echo ""
echo "==> All done! Start a new terminal or run: exec zsh"
