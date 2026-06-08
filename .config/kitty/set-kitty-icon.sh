#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ICON_DARK_ICNS="$SCRIPT_DIR/icon/kitty-dark.icns"
ICON_DARK_PNG="$SCRIPT_DIR/icon/kitty-dark.png"
PLIST_SRC="$SCRIPT_DIR/com.user.kitty-icon.plist"
PLIST_LABEL="com.user.kitty-icon"
PLIST_DEST="$HOME/Library/LaunchAgents/$PLIST_LABEL.plist"

_install_launchagent() {
  mkdir -p "$HOME/Library/LaunchAgents"
  ln -sf "$PLIST_SRC" "$PLIST_DEST"
  # bootstrap is idempotent on already-loaded services; unload first if needed
  launchctl bootout "gui/$(id -u)/$PLIST_LABEL" 2>/dev/null || true
  launchctl bootstrap "gui/$(id -u)" "$PLIST_DEST"
  echo "LaunchAgent installed — icon will be re-applied automatically after kitty updates"
}

case "$(uname -s)" in
  Darwin)
    KITTY_APP="/Applications/kitty.app"
    ICNS_DEST="$KITTY_APP/Contents/Resources/kitty.icns"

    # Exit early if our icon is already in place — every write this script makes
    # to the bundle would re-trigger WatchPaths, creating an infinite launchd loop.
    if cmp -s "$ICON_DARK_ICNS" "$ICNS_DEST" 2>/dev/null; then
      echo "kitty icon already applied"
      # --install re-registers the LaunchAgent even when the icon is current
      if [[ "${1:-}" == "--install" ]]; then
        _install_launchagent
      fi
      exit 0
    fi

    # --watch is passed by the plist so the retry loop can handle the bundle being
    # temporarily absent during brew upgrade. Without it, fail fast immediately.
    if [[ "${1:-}" != "--watch" ]]; then
      if [[ ! -d "$KITTY_APP" ]]; then
        echo "error: kitty not found at $KITTY_APP" >&2
        exit 1
      fi
      if [[ ! -w "$KITTY_APP" ]]; then
        echo "error: permission denied — $KITTY_APP is not writable by $(whoami)" >&2
        exit 1
      fi
    fi

    # --watch: WatchPaths fires while Homebrew is mid-install and the bundle is
    # temporarily absent — let the retry loop handle the missing directory.
    for i in {1..10}; do
      if [[ -f "$ICNS_DEST" ]] && cp "$ICON_DARK_ICNS" "$ICNS_DEST" 2>/dev/null; then
        break
      fi
      if [[ $i -eq 10 ]]; then
        if [[ ! -d "$KITTY_APP" ]]; then
          echo "error: kitty not found at $KITTY_APP" >&2
        else
          echo "error: could not write to $ICNS_DEST after retries" >&2
        fi
        exit 1
      fi
      sleep 3
    done

    # macOS prefers CFBundleIconName (asset catalog) over CFBundleIconFile (.icns).
    # Remove it so the system reads kitty.icns, which we control.
    /usr/libexec/PlistBuddy -c "Delete :CFBundleIconName" \
      "$KITTY_APP/Contents/Info.plist" 2>/dev/null || true

    # Re-sign ad-hoc after modifying sealed resources; preserve existing entitlements
    # (JIT, library-validation exceptions, etc.) that kitty may carry.
    codesign --force --deep --sign - --preserve-metadata=entitlements,requirements,flags "$KITTY_APP"
    touch "$KITTY_APP"

    # Flush Launch Services DB so Dock/Finder pick up the new icon immediately.
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$KITTY_APP" || true

    killall Dock || true

    echo "kitty icon applied — you may need to relaunch kitty for the change to appear"

    # Register the LaunchAgent AFTER the icon is fully applied. Registering first
    # with RunAtLoad=true would trigger a concurrent background run that races
    # with this foreground process over codesign and cp.
    if [[ "${1:-}" == "--install" ]]; then
      _install_launchagent
    fi
    ;;

  Linux)
    HICOLOR_DIR="$HOME/.local/share/icons/hicolor"
    ICON_DEST="$HICOLOR_DIR/256x256/apps"
    mkdir -p "$ICON_DEST"
    cp "$ICON_DARK_PNG" "$ICON_DEST/kitty.png"

    if command -v gtk-update-icon-cache &>/dev/null; then
      gtk-update-icon-cache --force --quiet "$HICOLOR_DIR"
    fi

    # Create a user-level .desktop override only when the system entry uses a
    # non-standard icon path. Most kitty packages already ship Icon=kitty, so
    # in that case the hicolor entry above is sufficient and no override is needed.
    DESKTOP_SRC=""
    IFS=: read -ra _xdg_dirs <<< "${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
    for _dir in "${_xdg_dirs[@]}"; do
      candidate="$_dir/applications/kitty.desktop"
      if [[ -f "$candidate" ]]; then
        DESKTOP_SRC="$candidate"
        break
      fi
    done

    DESKTOP_DEST="$HOME/.local/share/applications/kitty.desktop"
    if [[ -n "$DESKTOP_SRC" ]]; then
      if ! grep -q '^Icon=kitty$' "$DESKTOP_SRC"; then
        # Only write/overwrite if we own the file (signature comment) or it doesn't exist yet.
        # This preserves user-modified overrides while keeping our managed copy up to date.
        if [[ ! -f "$DESKTOP_DEST" ]] || grep -q '# Modified by set-kitty-icon.sh' "$DESKTOP_DEST"; then
          mkdir -p "$(dirname "$DESKTOP_DEST")"
          cp "$DESKTOP_SRC" "$DESKTOP_DEST"
          sed -i 's|^Icon=.*|Icon=kitty|' "$DESKTOP_DEST"
          echo "# Modified by set-kitty-icon.sh" >> "$DESKTOP_DEST"
        fi
      else
        # System icon is now standard — remove our override if we created it.
        if [[ -f "$DESKTOP_DEST" ]] && grep -q '# Modified by set-kitty-icon.sh' "$DESKTOP_DEST"; then
          rm "$DESKTOP_DEST"
        fi
      fi
    fi

    echo "kitty icon applied"
    ;;

  *)
    echo "error: unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac
