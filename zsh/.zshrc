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
alias la='eza -lah --git'
alias lt='eza --tree --level=2 --icons --git'
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
[ -s "/home/luongov/.bun/_bun" ] && source "/home/luongov/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
