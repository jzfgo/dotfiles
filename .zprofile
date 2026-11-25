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

# Opt out of CLI telemetry
export DO_NOT_TRACK=1                              # cross-tool convention: Claude Code, Bun, Supabase, gh…
export DISABLE_TELEMETRY=1                         # Claude Code (Statsig)
export DISABLE_ERROR_REPORTING=1                   # Claude Code (Sentry)

export GH_TELEMETRY=false                          # GitHub CLI (takes precedence over DO_NOT_TRACK)
export HOMEBREW_NO_ANALYTICS=1                     # Homebrew
export CLOUDSDK_CORE_DISABLE_USAGE_REPORTING=true  # gcloud
export RESEND_TELEMETRY_DISABLED=1                 # Resend CLI

export WRANGLER_SEND_METRICS=false                 # Cloudflare
export NEXT_TELEMETRY_DISABLED=1                   # Next.js
export ASTRO_TELEMETRY_DISABLED=1                  # Astro
export VERCEL_TELEMETRY_DISABLED=1                 # Vercel CLI

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME/bin:"*) ;;
*) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

# Machine-local setup (not tracked; platform- or host-specific PATH entries)
[[ -f ~/.zprofile.local ]] && source ~/.zprofile.local
