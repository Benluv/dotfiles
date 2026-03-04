# dotfiles

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick Start (fresh machine)

```bash
git clone git@github.com:benluv/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh   # Installs all tools + symlinks configs
```

If tools are already installed and you just want to symlink configs:

```bash
./install.sh
```

## Structure

Each top-level directory is a **stow module** — its contents mirror `$HOME`.

```
dotfiles/
├── zsh/           # .zshrc, .p10k.zsh (Powerlevel10k theme)
├── tmux/          # .tmux.conf, .config/tmux/battery.sh
├── git/           # .gitconfig, .ssh/config
├── opencode/      # .config/opencode/package.json
├── k9s/           # .config/k9s/ (Kubernetes TUI)
├── htop/          # .config/htop/htoprc
├── install.sh     # Symlinks dotfiles via stow
├── bootstrap.sh   # Installs tools on fresh Ubuntu/Debian
└── .gitignore
```

## Install individual modules

```bash
cd ~/dotfiles
stow zsh          # Only symlink zsh configs
stow tmux git     # Symlink tmux + git configs
```

## Remove symlinks

```bash
cd ~/dotfiles
stow -D zsh       # Remove zsh symlinks
```

## Adding new configs

1. Create a directory: `mkdir -p ~/dotfiles/newapp/.config/newapp`
2. Move/copy your config: `cp ~/.config/newapp/config.yaml ~/dotfiles/newapp/.config/newapp/`
3. Stow it: `stow newapp`
4. Add the module name to `ALL_MODULES` in `install.sh`
5. Commit and push

## Updating configs

Because stow creates **symlinks**, your live configs point directly into this repo.
Any changes you make to `~/.zshrc` (for example) are actually editing
`~/dotfiles/zsh/.zshrc`. Just commit and push:

```bash
cd ~/dotfiles
git add -A
git commit -m "update zsh aliases"
git push
```

On another machine, pull the changes:

```bash
cd ~/dotfiles
git pull
```

No re-stow needed — the symlinks already point to the right files.

## What's NOT tracked (and why)

| File | Reason |
|---|---|
| `.npmrc` | Contains auth tokens (secret) |
| `.git-credentials` | Contains GitHub tokens (secret) |
| SSH private keys | Never put private keys in a repo |
| `.zsh_history` | Machine-specific |
| Oh My Zsh, NVM, TPM plugins | Installed by `bootstrap.sh` |
| `/usr/local/bin/*` binaries | Installed by `bootstrap.sh` |

## Tools included

| Tool | Purpose | Config tracked? |
|---|---|---|
| zsh + Oh My Zsh | Shell | Yes (.zshrc, .p10k.zsh) |
| tmux + TPM | Terminal multiplexer | Yes (.tmux.conf) |
| eza | Modern `ls` | Via .zshrc aliases |
| bat | Modern `cat` | Via .zshrc alias |
| fd | Modern `find` | Via .zshrc fzf config |
| fzf | Fuzzy finder | Via .zshrc env vars |
| ripgrep | Modern `grep` | Via .zshrc `fr()` function |
| tldr | Simplified man pages | Installed by bootstrap |
| Neovim | Editor | Config dir exists but empty |
| k9s | Kubernetes TUI | Yes (.config/k9s/) |
| OpenCode | AI coding assistant | Yes (plugin config) |
