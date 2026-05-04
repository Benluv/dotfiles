#!/usr/bin/env bash
#
# bootstrap.sh — Install CLI tools and shell environment on a fresh Ubuntu/Debian machine.
#
# This script is IDEMPOTENT: running it multiple times is safe.
# It installs everything needed to make your dotfiles work:
#   - zsh + Oh My Zsh + Powerlevel10k + plugins
#   - tmux + TPM (Tmux Plugin Manager)
#   - Modern CLI tools: eza, bat, fd, fzf, ripgrep, tldr, zoxide, delta
#   - Neovim (latest stable from GitHub releases)
#   - NVM + latest LTS Node.js
#   - Bun (for OpenCode plugin)
#   - GNU Stow (for dotfile symlinks)
#   - OpenCode CLI
#
# Usage:
#   ./bootstrap.sh          # Install everything
#   ./bootstrap.sh --dry    # Show what would be installed

set -euo pipefail

DRY_RUN=false
[[ "${1:-}" == "--dry" ]] && DRY_RUN=true

# ── Colors ───────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${GREEN}[+]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
error()   { echo -e "${RED}[x]${NC} $*"; }
section() { echo -e "\n${BLUE}━━━ $* ━━━${NC}"; }

# ── Helpers ──────────────────────────────────────────────────────────────
is_installed() { command -v "$1" &>/dev/null; }

run() {
    if $DRY_RUN; then
        echo "  [dry-run] $*"
    else
        "$@"
    fi
}

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Detect environment ──────────────────────────────────────────────────
IS_WSL=false
if grep -qi microsoft /proc/version 2>/dev/null; then
    IS_WSL=true
    info "Detected WSL environment"
else
    info "Detected native Linux environment"
fi

# ── System packages ─────────────────────────────────────────────────────
section "System packages (apt)"

info "Updating package lists..."
run sudo apt-get update -qq

# Core utilities needed by everything else
PACKAGES=(
    git
    curl
    wget
    unzip
    stow
    tmux
    zsh
    build-essential   # Needed for compiling various tools
    cmake             # Build tool
    jq                # JSON processor
)

# Clipboard support for native Linux (not needed in WSL)
if ! $IS_WSL; then
    PACKAGES+=(xclip xsel)
fi

info "Installing: ${PACKAGES[*]}"
run sudo apt-get install -y -qq "${PACKAGES[@]}"

# ── Zsh as default shell ────────────────────────────────────────────────
section "Zsh"

if [ "$SHELL" != "$(which zsh)" ]; then
    info "Setting zsh as default shell..."
    run chsh -s "$(which zsh)"
    warn "Shell changed. Log out and back in for it to take effect."
else
    info "zsh is already the default shell"
fi

# ── Oh My Zsh ────────────────────────────────────────────────────────────
section "Oh My Zsh"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    run sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    info "Oh My Zsh already installed"
fi

# ── Zsh plugins ──────────────────────────────────────────────────────────
section "Zsh plugins"

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Powerlevel10k theme
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    info "Installing Powerlevel10k..."
    run git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        "$ZSH_CUSTOM/themes/powerlevel10k"
else
    info "Powerlevel10k already installed"
fi

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    info "Installing zsh-autosuggestions..."
    run git clone https://github.com/zsh-users/zsh-autosuggestions \
        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    info "zsh-autosuggestions already installed"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    info "Installing zsh-syntax-highlighting..."
    run git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    info "zsh-syntax-highlighting already installed"
fi

# ── Modern CLI tools ────────────────────────────────────────────────────
section "CLI tools"

# bat (cat replacement)
if ! is_installed bat; then
    info "Installing bat from GitHub..."
    BAT_VERSION=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
    ARCH=$(dpkg --print-architecture)
    if [ "$ARCH" = "amd64" ]; then BAT_ARCH="x86_64"; else BAT_ARCH="aarch64"; fi
    
    URL="https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat-v${BAT_VERSION}-${BAT_ARCH}-unknown-linux-musl.tar.gz"
    curl -fsSL "$URL" -o /tmp/bat.tar.gz
    mkdir -p /tmp/bat-download
    tar -xzf /tmp/bat.tar.gz -C /tmp/bat-download --strip-components=1
    run sudo mv /tmp/bat-download/bat /usr/local/bin/bat
    rm -rf /tmp/bat.tar.gz /tmp/bat-download
else
    info "bat already installed"
fi

# fd (find replacement)
if ! is_installed fd; then
    info "Installing fd from GitHub..."
    FD_VERSION=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
    ARCH=$(dpkg --print-architecture)
    if [ "$ARCH" = "amd64" ]; then FD_ARCH="x86_64"; else FD_ARCH="aarch64"; fi

    URL="https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-${FD_ARCH}-unknown-linux-musl.tar.gz"
    curl -fsSL "$URL" -o /tmp/fd.tar.gz
    mkdir -p /tmp/fd-download
    tar -xzf /tmp/fd.tar.gz -C /tmp/fd-download --strip-components=1
    run sudo mv /tmp/fd-download/fd /usr/local/bin/fd
    rm -rf /tmp/fd.tar.gz /tmp/fd-download
else
    info "fd already installed"
fi

# ripgrep
if ! is_installed rg; then
    info "Installing ripgrep from GitHub..."
    RG_VERSION=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep -Po '"tag_name": "\K[^"]*')
    ARCH=$(dpkg --print-architecture)
    if [ "$ARCH" = "amd64" ]; then RG_ARCH="x86_64"; else RG_ARCH="aarch64"; fi

    URL="https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-${RG_ARCH}-unknown-linux-musl.tar.gz"
    curl -fsSL "$URL" -o /tmp/rg.tar.gz
    mkdir -p /tmp/rg-download
    tar -xzf /tmp/rg.tar.gz -C /tmp/rg-download --strip-components=1
    run sudo mv /tmp/rg-download/rg /usr/local/bin/rg
    rm -rf /tmp/rg.tar.gz /tmp/rg-download
else
    info "ripgrep already installed"
fi

# fzf (latest from GitHub, apt version is often outdated)
if ! is_installed fzf; then
    info "Installing fzf from GitHub..."
    FZF_VERSION=$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest | jq -r '.tag_name' | sed 's/^v//')
    ARCH=$(dpkg --print-architecture)
    run curl -fsSL "https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_${ARCH}.tar.gz" | sudo tar -xz -C /usr/local/bin/
else
    info "fzf already installed"
fi

# eza (modern ls replacement — installed from official repo)
if ! is_installed eza; then
    info "Installing eza..."
    # eza has its own apt repo
    run sudo mkdir -p /etc/apt/keyrings
    run bash -c 'wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg'
    run bash -c 'echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list'
    run sudo apt-get update -qq
    run sudo apt-get install -y -qq eza
else
    info "eza already installed"
fi

# tldr (tealdeer — fast Rust implementation)
if ! is_installed tldr; then
    info "Installing tealdeer (tldr)..."
    ARCH=$(dpkg --print-architecture)
    if [ "$ARCH" = "amd64" ]; then
        TLDR_ARCH="x86_64"
    else
        TLDR_ARCH="aarch64"
    fi
    run curl -fsSL "https://github.com/tealdeer-rs/tealdeer/releases/latest/download/tealdeer-linux-${TLDR_ARCH}-musl" -o /tmp/tldr
    run chmod +x /tmp/tldr
    run sudo mv /tmp/tldr /usr/local/bin/tldr
    info "Updating tldr cache..."
    run tldr --update || true
else
    info "tldr already installed"
fi

# zoxide (smarter cd with frecency)
if ! is_installed zoxide; then
    info "Installing zoxide..."
    run curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
else
    info "zoxide already installed"
fi

# delta (better git diffs)
if ! is_installed delta; then
    info "Installing delta from GitHub..."
    DELTA_VERSION=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | grep -Po '"tag_name": "\K[^"]*')
    ARCH=$(dpkg --print-architecture)
    if [ "$ARCH" = "amd64" ]; then DELTA_ARCH="x86_64"; else DELTA_ARCH="aarch64"; fi
    
    URL="https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-${DELTA_ARCH}-unknown-linux-musl.tar.gz"
    curl -fsSL "$URL" -o /tmp/delta.tar.gz
    mkdir -p /tmp/delta-download
    tar -xzf /tmp/delta.tar.gz -C /tmp/delta-download --strip-components=1
    run sudo mv /tmp/delta-download/delta /usr/local/bin/delta
    rm -rf /tmp/delta.tar.gz /tmp/delta-download
else
    info "delta already installed"
fi

# ── Neovim ───────────────────────────────────────────────────────────────
section "Neovim"

if ! is_installed nvim; then
    info "Installing Neovim (latest stable)..."
    run sudo mkdir -p /opt/neovim
    NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | jq -r '.tag_name' | sed 's/^v//')
    run curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" -o /tmp/nvim.tar.gz
    run sudo tar -xzf /tmp/nvim.tar.gz -C /opt/neovim/
    run sudo ln -sf /opt/neovim/nvim-linux-x86_64 /opt/neovim/current
    run sudo ln -sf /opt/neovim/current/bin/nvim /usr/local/bin/nvim
    rm -f /tmp/nvim.tar.gz
else
    info "Neovim already installed: $(nvim --version | head -1)"
fi

# ── Tmux Plugin Manager ─────────────────────────────────────────────────
section "Tmux Plugin Manager (TPM)"

TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    info "Installing TPM..."
    run mkdir -p "$HOME/.config/tmux/plugins"
    run git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    info "TPM installed. After starting tmux, press 'prefix + I' to install plugins."
else
    info "TPM already installed"
fi

# ── Pyenv (Python version manager) ───────────────────────────────────────
section "Pyenv (Python version manager)"

export PYENV_ROOT="$HOME/.pyenv"
if [ ! -d "$PYENV_ROOT" ]; then
    info "Installing Pyenv..."
    run bash -c "$(curl -fsSL https://pyenv.run)"
else
    info "Pyenv already installed"
fi

# ── NVM + Node.js ────────────────────────────────────────────────────────
section "NVM + Node.js"

export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
    info "Installing NVM..."
    run bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh)"
    # Source NVM so we can use it immediately
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
else
    info "NVM already installed"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
fi

if ! is_installed node; then
    info "Installing latest LTS Node.js..."
    run nvm install --lts
else
    info "Node.js already installed: $(node --version)"
fi

# ── Bun ──────────────────────────────────────────────────────────────────
section "Bun (JavaScript runtime)"

if ! is_installed bun; then
    info "Installing Bun..."
    run bash -c "$(curl -fsSL https://bun.sh/install)"
else
    info "Bun already installed: $(bun --version)"
fi

# ── OpenCode ─────────────────────────────────────────────────────────────
section "OpenCode"

if ! is_installed opencode; then
    info "Installing OpenCode..."
    run bash -c "$(curl -fsSL https://opencode.ai/install)"
else
    info "OpenCode already installed"
fi

# Install OpenCode plugin dependencies
if [ -f "$DOTFILES_DIR/opencode/.config/opencode/package.json" ]; then
    info "Installing OpenCode plugin dependencies..."
    if is_installed bun; then
        run bash -c "cd ~/.config/opencode && bun install"
    fi
fi

# ── Symlink dotfiles ────────────────────────────────────────────────────
section "Dotfiles"

info "Running install.sh to symlink dotfiles..."
run bash "$DOTFILES_DIR/install.sh"

# ── etraid linter/formatter dependencies ────────────────────────────────
section "etraid linter/formatter (eslint + prettier)"

ETRAID_DIR="$HOME/.config/etraid_linter_formatter"
if [ -f "$ETRAID_DIR/package.json" ]; then
    if [ ! -d "$ETRAID_DIR/node_modules" ]; then
        info "Installing etraid linter/formatter dependencies..."
        run bash -c "cd '$ETRAID_DIR' && npm install"
    else
        info "etraid linter/formatter dependencies already installed"
    fi
else
    warn "etraid_linter_formatter package.json not found — skipping npm install"
fi

# ── Summary ──────────────────────────────────────────────────────────────
section "Bootstrap complete!"

echo ""
info "Installed tools:"
echo "  Shell:     zsh + Oh My Zsh + Powerlevel10k"
echo "  Terminal:  tmux + TPM + Catppuccin"
echo "  CLI:       eza, bat, fd, fzf, ripgrep, tldr, zoxide, delta"
echo "  Editor:    Neovim"
echo "  Runtime:   Node.js (via NVM), Bun, Python (via Pyenv)"
echo "  AI:        OpenCode"
echo ""
info "Remaining manual steps:"
echo "  1. Log out and back in (if shell was changed to zsh)"
echo "  2. Open tmux and press 'prefix + I' to install tmux plugins"
echo "  3. Run 'p10k configure' if you want to reconfigure the prompt"
echo "  4. Set up SSH keys:  ssh-keygen -t ed25519 -C 'your@email.com'"
echo "  5. Set up Git credentials:  gh auth login  or  git credential store"
echo ""
if $IS_WSL; then
    info "WSL detected — clipboard uses win32yank.exe (should already be in PATH)"
else
    info "Native Linux — clipboard uses xclip/xsel (installed)"
fi
