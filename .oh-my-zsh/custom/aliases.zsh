alias sshcfg="nvim ~/.ssh/config"
alias zshcfg="nvim ~/.zshrc"
alias omzcfg="nvim ~/.oh-my-zsh"
alias ktycfg="nvim ~/.config/kitty/kitty.conf"
alias vimcfg="vim ~/.vimrc"

alias v="nvim"

alias lg="lazygit"

# neonctl has no env var for telemetry, only a per-invocation flag
alias neonctl="neonctl --no-analytics"
alias neon="neon --no-analytics"

alias kkn='clear && command -v cmatrix >/dev/null 2>&1 && cmatrix -Ba -u 2 -C green || echo "The Matrix has you... (install cmatrix)"'

# Re-apply the custom kitty icon after brew operations that replace kitty.app.
# NSWorkspace.setIcon requires an active user session, which the brew hook has.
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

# En betaespera (y sus worktrees, que viven dentro) usa la cuenta de elenica.
# Solo si claude-ele existe en esta máquina; si no, cae al claude normal.
claude() {
  if [[ $PWD == $HOME/Projects/personal/betaespera(|/*) ]] && (( $+commands[claude-ele] )); then
    claude-ele "$@"
  else
    command claude "$@"
  fi
}

# Machine-local aliases (not tracked; may contain host- or OS-specific setup)
[[ -f ~/.zsh_aliases.local ]] && source ~/.zsh_aliases.local
