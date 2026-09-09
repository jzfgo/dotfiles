# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:/Users/javi/.docker/bin"
# End of Docker Desktop section.

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

# Machine-local setup (not tracked; platform- or host-specific PATH entries)
[[ -f ~/.zprofile.local ]] && source ~/.zprofile.local
