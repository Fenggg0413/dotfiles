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

# ---- 4. Install Powerlevel10k ----
echo "==> Installing Powerlevel10k theme..."
[[ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]] || \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"

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
config_symlink "starship.toml"
config_symlink "bat/config"
config_symlink "neofetch/config.conf"

# ---- 8. Create .zshrc.local / .bashrc.local templates if missing ----
[[ -f "$HOME/.zshrc.local" ]] || touch "$HOME/.zshrc.local"
[[ -f "$HOME/.bashrc.local" ]] || touch "$HOME/.bashrc.local"

echo ""
echo "==> All done! Start a new terminal or run: exec zsh"
