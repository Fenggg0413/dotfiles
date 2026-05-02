# dotfiles

Cross-platform dotfiles — works on **macOS**, **Linux**, and **WSL2**.

## Quick start

```bash
git clone https://github.com/Fen4/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Install system packages (tmux, zsh, fzf, etc.)
bash install.sh

# Set up zsh, oh-my-zsh, plugins, and symlinks
bash init.sh
```

After that, open a new terminal. On first launch, p10k will walk you through theme configuration.

## What's included

| File | Purpose |
|------|---------|
| `.zshrc` | Main zsh config (shared + per-platform) |
| `.bashrc` | Bash config for Linux/WSL2 |
| `.vimrc` | Vim/Neovim settings |
| `.tmux.conf` | Tmux config |
| `.gitconfig` | Shared git settings |
| `.p10k.zsh` | Powerlevel10k theme |
| `config/git/ignore` | Global gitignore rules |
| `config/tmux/tmux.conf.local` | Tmux theme & status bar (oh-my-tmux) |

## Per-machine overrides

Files that are **not synced** — create them on each machine for local settings:

| File | Purpose |
|------|---------|
| `~/.zshrc.local` | Machine-specific zsh settings |
| `~/.bashrc.local` | Machine-specific bash settings |
| `~/.gitconfig.local` | Machine-specific git settings (credentials, etc.) |

`init.sh` will create empty `.local` templates automatically. The `.gitconfig.local` will be pre-filled with the correct `gh` credential helper path if `gh` is installed.

## How platform detection works

`.zshrc` and `.bashrc` detect the OS at startup:

```zsh
_OS="$(uname)"
# _OS = "Darwin" → macOS
# _OS = "Linux"  → Linux / WSL2
```

WSL2 is detected via `/proc/version` and gets Windows interop aliases (`open`, `winget`, `winhome`).

## Troubleshooting

**Font issues:** Install [MesloLGS NF](https://github.com/romkatv/powerlevel10k-media) fonts and configure your terminal to use them.

**p10k reconfiguration:** Run `p10k configure` in any zsh session.
