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

Use the `add-config.sh` helper — it handles everything automatically:

```bash
~/dotfiles/add-config.sh ~/.config/newapp/config.yaml
```

Or use the shell function (available after sourcing `.zshrc`):

```bash
add-config ~/.config/newapp/config.yaml
```

It will:
1. Create the module directory structure inside `~/dotfiles/`
2. Move the file into the repo
3. Run stow to create the symlink back to the original location
4. Register the module in `install.sh`

After that, edit the file at its original path as normal — changes go directly into the repo via the symlink.

For files directly in `$HOME` (like `.zshrc`, `.tmux.conf`) it will prompt you for a module name.

## Updating configs

Because stow creates **symlinks**, your live configs point directly into this repo.
Any changes you make to `~/.config/k9s/config.yaml` (for example) are already
in `~/dotfiles/k9s/.config/k9s/config.yaml`. Just commit when ready:

```bash
dotfiles-sync
```

The `dotfiles-sync` shell function (defined in `.zshrc`) stages all changes,
shows you a diff summary, and prompts for a commit message. To push:

```bash
cd ~/dotfiles && git push
```

On another machine, pull the changes:

```bash
cd ~/dotfiles && git pull
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
