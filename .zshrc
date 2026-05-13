# =============================================================================
# Cross-platform .zshrc — macOS / Linux / WSL2
# =============================================================================

# Platform detection (must be early)
_OS="$(uname)"
# Detect WSL2 specifically (useful for Windows interop)
if [[ "$_OS" == "Linux" ]] && grep -qi microsoft /proc/version 2>/dev/null; then
    _IS_WSL=1
else
    _IS_WSL=0
fi

# ---- User-local bin paths (must come before oh-my-zsh / `command -v` checks) ----
# install.sh may place tools at ~/.local/bin (starship), ~/.cargo/bin (yazi),
# or ~/.bun/bin (bun) — make sure these are on PATH from login shells.
[[ -d "$HOME/.local/bin" ]] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/.cargo/bin" ]] && [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]] && export PATH="$HOME/.cargo/bin:$PATH"
if [[ -d "$HOME/.bun/bin" ]]; then
    export BUN_INSTALL="$HOME/.bun"
    [[ ":$PATH:" != *":$HOME/.bun/bin:"* ]] && export PATH="$BUN_INSTALL/bin:$PATH"
    [[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
fi

# ---- Oh-my-zsh core ----
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
zstyle ':omz:update' mode auto

# Plugins: shared + platform-specific
plugins=(git zsh-autosuggestions zsh-syntax-highlighting rand-quote cp history colored-man-pages copyfile copypath)
# macOS-only plugin (won't exist on Linux)
[[ "$_OS" == "Darwin" ]] && plugins+=(macos)

source $ZSH/oh-my-zsh.sh

# ---- Shared aliases (all platforms) ----
alias sp="export https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 all_proxy=socks5://127.0.0.1:7897; echo 'Set proxy successfully'"
alias usp="unset http_proxy; unset https_proxy; unset all_proxy; echo 'Unset proxy successfully'"
alias tt="curl -s -o /dev/null -w '%{http_code}' www.google.com && echo ''"
if command -v lsd >/dev/null 2>&1; then
    alias ls=lsd
    alias ll='lsd -la'
    alias tree='lsd --tree'
fi
alias cl="clear"
alias ec="echo $?"
alias gs="git status"
alias gla='git log --all --graph --decorate'
alias glao='git log --all --graph --decorate --oneline'
alias mv="mv -i"
if command -v nvim >/dev/null 2>&1; then
    alias vi=nvim
    alias vim=nvim
    export EDITOR=nvim
    export VISUAL=nvim
fi
alias python=python3
alias py=python3
alias pip=pip3
if command -v yazi >/dev/null 2>&1; then
  function yz() {
    local tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    yazi --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      cd -- "$cwd"
    fi
    rm -f -- "$tmp"
  }
fi
alias sf='npx skills find'

bindkey -v

# Go
export GOPROXY=https://goproxy.cn
export GOPRIVATE=git.xxx.com

# fzf
if command -v fzf &>/dev/null && fzf --zsh >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
fi

# zoxide
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# starship prompt
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# ---- macOS-specific ----
if [[ "$_OS" == "Darwin" ]]; then
    # zsh-completions via Homebrew
    if command -v brew &>/dev/null; then
        FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"
        autoload -Uz compinit
        compinit
    fi

    alias ty='open -a Typora'
    alias disablesleep='sudo pmset -a disablesleep 1'
    alias ablesleep='sudo pmset -a disablesleep 0'

    # broot
    [[ -f "$HOME/.config/broot/launcher/bash/br" ]] && source "$HOME/.config/broot/launcher/bash/br"

    # Antigravity
    [[ -d "$HOME/.antigravity/antigravity/bin" ]] && export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

    # kiro shell integration
    [[ "$TERM_PROGRAM" == "kiro" ]] && command -v kiro &>/dev/null && . "$(kiro --locate-shell-integration-path zsh)"

    # clash-proxy (if script exists)
    if [[ -f "$HOME/Project/script/clash-proxy.sh" ]]; then
        alias clashproxy="$HOME/Project/script/clash-proxy.sh"
        alias cpo="clashproxy off-all"
    fi
fi

# ---- Linux / WSL2 specific ----
if [[ "$_OS" == "Linux" ]]; then
    # WSL2: useful aliases for Windows interop
    if (( _IS_WSL )); then
        alias open="explorer.exe"
        alias winget="winget.exe"
        # Access Windows home from WSL
        _WIN_HOME="$(wslpath "$(wslvar USERPROFILE 2>/dev/null)" 2>/dev/null)"
        [[ -n "$_WIN_HOME" ]] && alias winhome="cd $_WIN_HOME"
    fi

    # Linux: xdg-open as equivalent of macOS 'open'
    alias o="xdg-open"

    # apt ships bat as `batcat` and fd-find as `fdfind` — alias to expected names
    command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1 && alias bat=batcat
    command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1 && alias fd=fdfind

    # ssh agent (common on Linux desktops)
    # export SSH_ASKPASS="/usr/bin/ksshaskpass"
fi

# ---- Per-machine local overrides (not synced) ----
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# ---- .local/bin/env (shared across bash/zsh, if it exists) ----
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# ---- g++ ----
alias compile='g++ -std=c++2a -Wall'
