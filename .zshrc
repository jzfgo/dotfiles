# ~/.zshrc

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Core shell setup
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(direnv gcloud zoxide zsh-nvm)
source "$ZSH/oh-my-zsh.sh"

# User configuration
[[ -f $HOME/.secrets ]] && source $HOME/.secrets

# Personal aliases
alias sshcfg="nvim ~/.ssh/config"
alias zshcfg="nvim ~/.zshrc"
alias omzcfg="nvim ~/.oh-my-zsh"
alias v="nvim"
alias ls="eza -lhaG"
alias ll="eza -la"

# Optional command completions
if command -v zmx >/dev/null 2>&1; then
  eval "$(command zmx c zsh)"
fi

if command -v wt >/dev/null 2>&1; then
  eval "$(command wt config shell init zsh)"
fi

if [[ -d "$HOME/.docker/completions" ]]; then
  fpath=("$HOME/.docker/completions" "$fpath[@]")
fi

if [[ -d "$HOME/.zfunc" ]]; then
  fpath=("$HOME/.zfunc" "$fpath[@]")
fi

autoload -Uz compinit
compinit

zstyle ':completion:*' menu select

# Prompt
if [[ -f "$HOME/.p10k.zsh" ]]; then
  source "$HOME/.p10k.zsh"
fi

prompt_my_zmx_session() {
  if [[ -n "$ZMX_SESSION" ]]; then
    p10k segment -b '%k' -f '%f' -t "[$ZMX_SESSION]"
  fi
}

POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=my_zmx_session

# External tool initialization
if [[ -f "$HOME/.config/broot/launcher/bash/br" ]]; then
  source "$HOME/.config/broot/launcher/bash/br"
fi
