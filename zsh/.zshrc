# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Theme → Powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  fzf
)

source $ZSH/oh-my-zsh.sh

# Powerlevel10k wizard on first start
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# fzf key bindings and fuzzy completion (the magic Ctrl+R and ** completion)
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh

# Or if the files live somewhere else in newer Ubuntu:
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export PATH="$HOME/.local/bin:$PATH"

# ─── fzf with gorgeous live preview (this is the magic you wanted) ─────
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# ← This line gives you the code preview on the right side
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}' --preview-window right:60%:border-left --height=90% --border"

# Bonus: directory preview with nice tree (level 3) when you press Alt+C
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=3 --icons=always --color=always {}' --preview-window right:50%:border-left"

alias ls='eza --git'           
alias lh='eza --icons -a --git'
alias ll='eza -lgh --icons --git'
alias la='eza -lah --icons --git'
alias l=la
alias lt='eza --tree --level=2 --icons --git'
alias ltgi='eza --tree --level=3 --icons --git-ignore'
alias cat='bat'
alias nokubectl='minikube kubectl --'

# Initialize zoxide
eval "$(zoxide init zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export NODE_PATH="$HOME/.nvm/versions/node/$(node -v)/lib/node_modules${NODE_PATH:+:$NODE_PATH}"

# Find Text (Interactive Ripgrep)
fr() {
  rg --column --line-number --no-heading --color=always --smart-case -- "$*" | fzf --ansi \
    --delimiter : \
    --preview 'bat --color=always --style=numbers --line-range={2}:500 {1}' \
    --preview-window 'right:60%:+{2}-10'
}

# VSCode integrated termianal integration
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# zoxide (cd replacement)
eval "$(zoxide init zsh)"

# ─── dotfiles helpers ────────────────────────────────────────────────────

# dotfiles-sync: stage all changes in the dotfiles repo, show status,
# then optionally commit with a message you provide.
dotfiles-sync() {
  local dotfiles_dir="$HOME/dotfiles"
  echo ""
  echo "==> Staging all changes in $dotfiles_dir"
  git -C "$dotfiles_dir" add -A
  echo ""
  git -C "$dotfiles_dir" status
  echo ""
  read -r "msg?Commit message (leave blank to skip commit): "
  if [[ -n "$msg" ]]; then
    git -C "$dotfiles_dir" commit -m "$msg"
    echo ""
    echo "Done. Run 'git push' inside ~/dotfiles to push to remote."
  else
    echo "Staged but not committed. Run 'git commit' inside ~/dotfiles when ready."
  fi
}

# add-config: shortcut to ~/dotfiles/add-config.sh
add-config() {
  "$HOME/dotfiles/add-config.sh" "$@"
}

# >>> oh-my-opencode alias >>>
# Wrapper to run OpenCode with oh-my-opencode only when requested.
# Default behavior:
#   - `opencode` => vanilla OpenCode (no oh-my-opencode)
#   - `omo`      => OpenCode + oh-my-opencode (runtime-only override)
#
# Requirement:
#   - `~/.config/opencode/opencode.json` should NOT already contain oh-my-opencode.

omo() {
  local config_file="$HOME/.config/opencode/opencode.json"
  local tmp_dir
  tmp_dir=$(mktemp -d)

  # Copy the full config dir so OpenCode finds all its supporting files
  # -L dereferences symlinks (e.g. package.json -> dotfiles) so the temp dir has real files
  cp -rL "$HOME/.config/opencode/." "$tmp_dir/"

  # Inject oh-my-opencode into the plugin list in the temp copy
  node -e "
    const fs = require('fs');
    const cfg = JSON.parse(fs.readFileSync(process.argv[1], 'utf8'));
    const plugins = cfg.plugin || [];
    if (!plugins.some(p => /^oh-my-opencode(@.*)?$/.test(p))) {
      plugins.push('oh-my-opencode@latest');
    }
    cfg.plugin = plugins;
    fs.writeFileSync(process.argv[1], JSON.stringify(cfg, null, 2));
  " "$tmp_dir/opencode.json"

  # Run OpenCode pointing at the temp config dir, then clean up
  OPENCODE_CONFIG_DIR="$tmp_dir" opencode "$@"
  local exit_code=$?
  rm -rf "$tmp_dir"
  return $exit_code
}
#
#
# <<< oh-my-opencode alias <<<

# Pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
eval "$(pyenv virtualenv-init - zsh)"

# peon-ping quick controls
alias peon="bash /home/bluongo/.claude/hooks/peon-ping/peon.sh"
[ -f /home/bluongo/.claude/hooks/peon-ping/completions.bash ] && source /home/bluongo/.claude/hooks/peon-ping/completions.bash
