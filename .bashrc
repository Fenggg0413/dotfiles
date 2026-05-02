# =============================================================================
# Cross-platform .bashrc — Linux / WSL2 / macOS
# =============================================================================

_OS="$(uname)"
if [[ "$_OS" == "Linux" ]] && grep -qi microsoft /proc/version 2>/dev/null; then
    _IS_WSL=1
else
    _IS_WSL=0
fi

# Prompt
PS1='\u@\h:\w\$ '

# ---- Shared aliases ----
alias sp="export https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 all_proxy=socks5://127.0.0.1:7897; echo 'Set proxy successfully'"
alias usp="unset http_proxy; unset https_proxy; unset all_proxy; echo 'Unset proxy successfully'"
alias tt="curl -s -o /dev/null -w '%{http_code}' www.google.com && echo ''"
alias cl="clear"
alias gs="git status"
alias gla='git log --all --graph --decorate'
alias glao='git log --all --graph --decorate --oneline'
alias mv="mv -i"
alias vi=nvim
alias vim=nvim
alias python=python3
alias py=python3
alias pip=pip3

# Use vi mode in bash
set -o vi

# fzf
if command -v fzf &>/dev/null; then
    eval "$(fzf --bash)"
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
fi

# ---- Per-machine local overrides ----
[[ -f "$HOME/.bashrc.local" ]] && source "$HOME/.bashrc.local"

# ---- .local/bin/env ----
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"
