# =============================================================================
# Cross-platform .bashrc — Linux / WSL2 / macOS
# =============================================================================

_OS="$(uname)"
if [[ "$_OS" == "Linux" ]] && grep -qi microsoft /proc/version 2>/dev/null; then
    _IS_WSL=1
else
    _IS_WSL=0
fi

# ---- User-local bin paths (must come before `command -v` checks below) ----
# install.sh may install tools at ~/.local/bin (starship), ~/.cargo/bin (yazi),
# or ~/.bun/bin (bun) — make sure these are on PATH from login shells.
[[ -d "$HOME/.local/bin" ]] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/.cargo/bin" ]] && [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]] && export PATH="$HOME/.cargo/bin:$PATH"
if [[ -d "$HOME/.bun/bin" ]]; then
    export BUN_INSTALL="$HOME/.bun"
    [[ ":$PATH:" != *":$HOME/.bun/bin:"* ]] && export PATH="$BUN_INSTALL/bin:$PATH"
    [[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
fi

# Prompt
PS1='\u@\h:\w\$ '

# ---- Shared aliases ----
alias sp="export https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 all_proxy=socks5://127.0.0.1:7897; echo 'Set proxy successfully'"
alias usp="unset http_proxy; unset https_proxy; unset all_proxy; echo 'Unset proxy successfully'"
alias tt="curl -s -o /dev/null -w '%{http_code}' www.google.com && echo ''"
if command -v lsd >/dev/null 2>&1; then
    alias ls=lsd
    alias ll='lsd -la'
    alias tree='lsd --tree'
fi
alias cl="clear"
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
command -v yazi >/dev/null 2>&1 && alias js="yazi"

# Use vi mode in bash
set -o vi

# fzf
if command -v fzf &>/dev/null; then
    eval "$(fzf --bash)"
fi

# zoxide
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
fi

# ---- macOS-specific ----
if [[ "$_OS" == "Darwin" ]]; then
    # macOS bash is usually v3; suggest zsh instead
    # But keep basic functionality for those who use it
    [[ -f "$HOME/.config/broot/launcher/bash/br" ]] && source "$HOME/.config/broot/launcher/bash/br"
fi

# ---- Linux / WSL2-specific ----
if [[ "$_OS" == "Linux" ]]; then
    if (( _IS_WSL )); then
        alias open="explorer.exe"
        alias winget="winget.exe"
        _WIN_HOME="$(wslpath "$(wslvar USERPROFILE 2>/dev/null)" 2>/dev/null)"
        [[ -n "$_WIN_HOME" ]] && alias winhome="cd $_WIN_HOME"
    fi
    alias o="xdg-open"

    # apt ships bat as `batcat` and fd-find as `fdfind` — alias to expected names
    command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1 && alias bat=batcat
    command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1 && alias fd=fdfind
fi

# ---- Per-machine local overrides ----
[[ -f "$HOME/.bashrc.local" ]] && source "$HOME/.bashrc.local"

# ---- .local/bin/env ----
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"
