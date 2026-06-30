#
# ~/.zprofile
#

# Re-establish Homebrew PATH after macOS path_helper reorders it in /etc/zprofile
# homebrew — must run before PATH block so $HOMEBREW_PREFIX is set
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

export EDITOR="$(command -v nvim || command -v vim || command -v vi 2>/dev/null)"
export VISUAL="$EDITOR"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME/bin:"*) ;;
*) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

[[ -f ~/.zprofile.local ]] && source ~/.zprofile.local

# Added by Obsidian
[[ $OSTYPE == darwin* && -d "/Applications/Obsidian.app/Contents/MacOS" ]] &&
  export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
