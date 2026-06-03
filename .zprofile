#
# ~/.zprofile
#

export EDITOR="$(command -v nvim || command -v vim || command -v vi 2>/dev/null)"
export VISUAL="$EDITOR"

[[ -f ~/.zprofile.local ]] && source ~/.zprofile.local
