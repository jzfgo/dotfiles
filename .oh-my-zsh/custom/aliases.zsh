alias sshcfg="nvim ~/.ssh/config"
alias zshcfg="nvim ~/.zshrc"
alias omzcfg="nvim ~/.oh-my-zsh"
alias ktycfg="nvim ~/.config/kitty/kitty.conf"
alias vimcfg="vim ~/.vimrc"

alias v="nvim"

alias lg="lazygit"

alias kkn='clear && command -v cmatrix >/dev/null 2>&1 && cmatrix -Ba -u 2 -C green || echo "The Matrix has you... (install cmatrix)"'

# Re-apply custom kitty icon after brew upgrades that replace kitty.app.
# The LaunchAgent watcher can't do this itself because background bash lacks the
# macOS App Management TCC permission required to write to /Applications bundles.
brew() {
  command brew "$@"
  local ec=$?
  case "$1" in
    upgrade|install|reinstall)
      # Trigger on mass upgrade (no extra args) or when kitty is explicitly named
      if [[ $# -eq 1 ]] || [[ " $* " == *" kitty"* ]]; then
        { printf '\n--- brew hook %s ---\n' "$(date '+%Y-%m-%dT%H:%M:%S')"; \
          "$HOME/.config/kitty/set-kitty-icon.sh"; } \
          >> "$HOME/Library/Logs/kitty-icon.log" 2>&1 || true
      fi
      ;;
  esac
  return $ec
}
