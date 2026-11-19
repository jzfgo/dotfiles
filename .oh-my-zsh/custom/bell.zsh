# Ring the bell when a command fails, so kitty's screen-shake shader fires.
# 130 (Ctrl+C / SIGINT) is ignored: interrupting a command isn't an error.
autoload -Uz add-zsh-hook
bell_on_error() {
  local s=$?
  (( s && s != 130 )) && printf '\a'
  return $s
}
add-zsh-hook precmd bell_on_error
