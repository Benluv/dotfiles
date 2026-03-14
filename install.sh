#!/usr/bin/env bash
#
# install.sh — Symlink dotfiles into $HOME using GNU Stow.
#
# Usage:
#   ./install.sh           # Install all modules
#   ./install.sh zsh tmux  # Install specific modules only
#
# What it does:
#   For each module (zsh, tmux, git, etc.), stow creates symlinks so that
#   e.g. ~/dotfiles/zsh/.zshrc -> ~/.zshrc
#
# To REMOVE symlinks later:  stow -D <module>  (from ~/dotfiles)
# To RE-STOW after changes:  stow -R <module>  (from ~/dotfiles)

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# All available modules (add new ones here as you create them)
ALL_MODULES=(zsh tmux git opencode k9s htop lazygit tealdeer nvim nextjs-nodejs turborepo)

# Use arguments if provided, otherwise install all
MODULES=("${@:-${ALL_MODULES[@]}}")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[x]${NC} $*"; }

# ── Check for stow ──────────────────────────────────────────────────────
if ! command -v stow &>/dev/null; then
    warn "GNU Stow not found. Installing..."
    if command -v apt-get &>/dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y -qq stow
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm stow
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y stow
    else
        error "Could not install stow. Install it manually and re-run."
        exit 1
    fi
fi

# ── Ensure target directories exist ─────────────────────────────────────
# Stow needs the parent directories to exist before it can create symlinks
# into them. Without this, stow would symlink the entire .config/ dir
# instead of individual files inside it.
# Clean version of your directory creation
# Ensure target directories exist to prevent Stow from symlinking the whole folder
info "Creating config directories..."
mkdir -p ~/.ssh ~/.config/{tmux,turborepo,nextjs-nodejs,opencode,k9s/skins,htop,lazygit,tealdeer,nvim}
mkdir -p ~/.config/{tmux,turborepo,nextjs-nodejs,opencode,k9s/skins,htop,lazygit,tealdeer,nvim} ~/.ssh

# ── Back up existing files that would conflict ──────────────────────────
backup_if_exists() {
    local file="$1"
    if [ -e "$file" ] && [ ! -L "$file" ]; then
        local backup="${file}.backup.$(date +%Y%m%d%H%M%S)"
        warn "Backing up existing $file -> $backup"
        mv "$file" "$backup"
    elif [ -L "$file" ]; then
        # Remove existing symlink (stow will recreate it)
        rm "$file"
    fi
}

# Files that stow will try to create symlinks for
MANAGED_FILES=(
    ~/.zshrc
    ~/.p10k.zsh
    ~/.tmux.conf
    ~/.config/tmux/battery.sh
    ~/.gitconfig
    ~/.ssh/config
    ~/.config/opencode/package.json
    ~/.config/opencode/opencode.json
    ~/.config/k9s/config.yaml
    ~/.config/k9s/aliases.yaml
    ~/.config/htop/htoprc
    ~/.config/lazygit/config.yml
    ~/.config/opencode/oh-my-opencode.json
    ~/.config/tealdeer/config.toml
    ~/.config/nextjs-nodejs/config.json
    ~/.config/turborepo/telemetry.json
)

info "Backing up any conflicting files..."
for file in "${MANAGED_FILES[@]}"; do
    backup_if_exists "$file"
done

# ─── Stow each module ────────────────────────────────────────────────────────
info "Stowing modules from $DOTFILES_DIR..."

# Ensure we are working with absolute paths to prevent WSL "Absolute/relative mismatch"
ABS_DOTFILES_DIR="$(readlink -f "$DOTFILES_DIR")"
ABS_TARGET_DIR="$(readlink -f "$HOME")"

for module in "${MODULES[@]}"; do
    if [ -d "$ABS_DOTFILES_DIR/$module" ]; then
        info "  Stowing: $module"
        # -d: source (dotfiles) | -t: target (home) | -R: restow (updates links)
        stow -v -R -d "$ABS_DOTFILES_DIR" -t "$ABS_TARGET_DIR" "$module"
    else
        warn "  Module '$module' directory not found, skipping."
    fi
done

# ── Post-install: source zsh config if we're in zsh ─────────────────────
if [ -n "${ZSH_VERSION:-}" ]; then
    info "Reloading zsh config..."
    source ~/.zshrc 2>/dev/null || true
fi

echo ""
info "Done! Dotfiles installed."
info "Your original files were backed up with .backup.<timestamp> suffix."
info ""
info "Next steps:"
info "  - Run ./bootstrap.sh to install CLI tools (if on a fresh machine)"
info "  - Run 'tmux source ~/.tmux.conf' to reload tmux config"
info "  - Run 'prefix + I' inside tmux to install TPM plugins"
