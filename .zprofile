#
# ~/.zprofile
#

export EDITOR="$(command -v nvim || command -v vim || command -v vi 2>/dev/null)"
export VISUAL="$EDITOR"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

[[ -f ~/.zprofile.local ]] && source ~/.zprofile.local
