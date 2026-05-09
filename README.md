# dotfiles

Cross-platform dotfiles — works on **macOS**, **Linux**, and **WSL2**.

## Quick start

```bash
git clone https://github.com/Fen4/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Install system packages (tmux, zsh, fzf, curl, neovim, yazi, lsd, bat, etc.)
bash install.sh

# Set up zsh, oh-my-zsh, oh-my-tmux, plugins, and symlinks
bash init.sh
```

After that, open a new terminal. The zsh prompt is powered by Starship via `config/starship.toml`.

## What's included

| File | Purpose |
|------|---------|
| `install.sh` | Package installation across package managers (Homebrew, apt, dnf, yum, pacman, apk) |
| `Brewfile` | macOS package manifest used by `brew bundle install` (taps + leaves + casks) |
| `init.sh` | Bootstrap: shell change, oh-my-zsh install, zsh plugin clone, oh-my-tmux install, symlink creation |
| `.zshrc` | Main zsh config (shared + per-platform aliases, fzf, Go proxy, p10k) |
| `.bashrc` | Bash config for Linux/WSL2 |
| `.vimrc` | Vim/Neovim settings |
| `.gitconfig` | Shared git settings (aliases, merge tool, etc.) |
| `config/starship.toml` | Starship prompt config |
| `config/git/ignore` | Global gitignore rules |
| `config/tmux/tmux.conf.local` | oh-my-tmux local overrides (prefix, plugins, keybindings) |
| `config/bat/config` | Bat syntax highlighting config (TwoDark theme, syntax mappings) |
| `config/fastfetch/config.jsonc` | Fastfetch system info display config (replaces deprecated neofetch) |
| `config/claude/` | Claude Code bootstrap snapshot — copied to `~/.claude/` on first run, no ongoing sync |
| `config/yazi/yazi.toml` | Yazi file manager config (preview, opener, file associations) |
| `config/yazi/keymap.toml` | Yazi keybindings (vim-style, zoxide, fd integration) |
| `config/yazi/theme.toml` | Yazi theme (Catppuccin Mocha inspired) |

## Neovim

The Neovim config is based on [LazyVim](https://www.lazyvim.org/), seeded from [LazyVim/starter](https://github.com/LazyVim/starter). It lives inside this repo at `config/nvim/` and is symlinked into `~/.config/nvim/` by `init.sh` (same pattern as yazi, starship, etc.). `lazy-lock.json` is tracked here so plugin versions reproduce across machines. The previous kickstart fork at [Fenggg0413/kickstart.nvim](https://github.com/Fenggg0413/kickstart.nvim) is kept on GitHub as an archive only.

## Tmux

Tmux is configured using [oh-my-tmux](https://github.com/gpakosz/.tmux).

`init.sh` installs the upstream config to:

```text
~/.local/share/tmux/oh-my-tmux/.tmux.conf
```

and links it via the XDG path:

```text
~/.config/tmux/tmux.conf
```

This repo manages the local override:

```text
config/tmux/tmux.conf.local -> ~/.config/tmux/tmux.conf.local
```

Key local overrides:
- Prefix: `Ctrl-a` (only prefix, `Ctrl-b` disabled)
- Vi-mode keybindings, mouse enabled
- Scrollback history: 65536 lines
- Window/pane indexes start at 1
- Escape delay set to 0
- `Ctrl-a r` to reload config, `Ctrl-a e` to toggle sync input
- System clipboard integration
- Plugins: `tmux-copycat` (enhanced search/copy), `tmux-resurrect` (save/restore sessions)

Full details in `config/tmux/README.md`.

## Yazi

Yazi is a terminal file manager with vim-style keybindings. Config includes:

- **yazi.toml**: Hidden files off, alphabetical sort, directory-first; image/video/audio/pdf/archive open with system default; text/config files open in nvim; 5 micro / 10 macro workers
- **keymap.toml**: Full vim-style navigation (`hjkl`, `gg`, `G`, `Ctrl-u/d`), zoxide integration (`z`), fd search (`s`/`S`), fzf find (`/`), visual mode (`v`/`V`), yank/paste (`y`/`p`/`x`)
- **theme.toml**: Catppuccin Mocha inspired color scheme

## Per-machine overrides

Files that are **not synced** — create them on each machine for local settings:

| File | Purpose |
|------|---------|
| `~/.zshrc.local` | Machine-specific zsh settings |
| `~/.bashrc.local` | Machine-specific bash settings |
| `~/.gitconfig.local` | Machine-specific git settings (credentials, etc.) |

`init.sh` will create empty `.local` templates automatically. The `.gitconfig.local` will be pre-filled with the correct `gh` credential helper path if `gh` is installed.

## Troubleshooting

**Font issues:** Use a Nerd Font (Recommend JetBrainsMono Nerd Font) in terminal so Starship and terminal UI icons render correctly.

**Apple Silicon Macs:** After installing Homebrew, `brew` is at `/opt/homebrew/bin/brew` but not on PATH yet. `install.sh` and `init.sh` both detect this case automatically — `init.sh` also appends `eval "$(/opt/homebrew/bin/brew shellenv)"` to `~/.zprofile` so future shells pick it up. If `bash install.sh` complains brew isn't found, run that `eval` once by hand and try again.

**Linux: missing optional packages.** `install.sh` reports any optional packages that didn't install at the end of its run. Most commonly `yazi`, `starship`, and `bun` aren't in distro repos and are installed from upstream (cargo / official scripts). If those upstream installs fail (no network, etc.), follow the install instructions on each tool's website.

**Linux: bat / fd not found?** On Debian/Ubuntu the binaries are named `batcat` and `fdfind`. The dotfiles `.zshrc`/`.bashrc` already alias them to `bat` and `fd` for you.
