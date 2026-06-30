#
# ~/.zshrc
#

# Core shell setup
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(direnv eza gcloud zoxide zsh-nvm)

# fpath additions must come before oh-my-zsh (which calls compinit)
if [[ -d "$HOME/.docker/completions" ]]; then
  fpath=("$HOME/.docker/completions" "$fpath[@]")
fi

if [[ -d "$HOME/.zfunc" ]]; then
  fpath=("$HOME/.zfunc" "$fpath[@]")
fi

source "$ZSH/oh-my-zsh.sh"

# User configuration
[[ -f $HOME/.secrets ]] && source $HOME/.secrets

# Optional command completions (must come after compinit so compdef is available)
if command -v zmx >/dev/null 2>&1; then
  eval "$(command zmx c zsh)"
fi

if command -v wt >/dev/null 2>&1; then
  eval "$(command wt config shell init zsh)"
fi

if command -v pnpm >/dev/null 2>&1; then
  eval "$(pnpm completion zsh)"
fi

zstyle ':completion:*' menu select

# Prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# External tool initialization
if [[ -f "$HOME/.config/broot/launcher/bash/br" ]]; then
  source "$HOME/.config/broot/launcher/bash/br"
fi

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
