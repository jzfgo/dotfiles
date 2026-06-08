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
    # --install: register the LaunchAgent that re-runs this script on kitty updates
    if [[ "${1:-}" == "--install" ]]; then
      _install_launchagent
      exit 0
    fi

    KITTY_APP="/Applications/kitty.app"

    # When triggered by the LaunchAgent WatchPaths fires the moment Homebrew
    # starts replacing the bundle — the icns may not exist yet or be locked.
    # Retry for up to ~30s to let the install finish.
    ICNS_DEST="$KITTY_APP/Contents/Resources/kitty.icns"
    for i in $(seq 1 10); do
      if [[ -f "$ICNS_DEST" ]] && cp "$ICON_DARK_ICNS" "$ICNS_DEST" 2>/dev/null; then
        break
      fi
      [[ $i -eq 10 ]] && { echo "error: could not write to $ICNS_DEST after retries" >&2; exit 1; }
      sleep 3
    done
    touch "$KITTY_APP"

    # Flush per-user icon caches (no sudo needed on macOS 12+)
    rm -rf "$HOME/Library/Caches/com.apple.IconServicesAgent" 2>/dev/null || true
    find "$HOME/Library/Caches" -name "com.apple.iconservices" -exec rm -rf {} + 2>/dev/null || true
    killall Dock

    echo "kitty icon applied — you may need to relaunch kitty for the change to appear"
    ;;

  Linux)
    HICOLOR_DIR="$HOME/.local/share/icons/hicolor"
    ICON_DEST="$HICOLOR_DIR/256x256/apps"
    mkdir -p "$ICON_DEST"
    cp "$ICON_DARK_PNG" "$ICON_DEST/kitty.png"

    if command -v gtk-update-icon-cache &>/dev/null; then
      gtk-update-icon-cache --force --quiet "$HICOLOR_DIR"
    fi

    # Create or patch a user-level .desktop override so the window manager
    # picks up the icon even if the system .desktop entry has an absolute path.
    DESKTOP_SRC=""
    for candidate in \
      "/usr/share/applications/kitty.desktop" \
      "/usr/local/share/applications/kitty.desktop"; do
      [[ -f "$candidate" ]] && DESKTOP_SRC="$candidate" && break
    done

    DESKTOP_DEST="$HOME/.local/share/applications/kitty.desktop"
    if [[ -n "$DESKTOP_SRC" && ! -f "$DESKTOP_DEST" ]]; then
      mkdir -p "$(dirname "$DESKTOP_DEST")"
      cp "$DESKTOP_SRC" "$DESKTOP_DEST"
    fi

    if [[ -f "$DESKTOP_DEST" ]]; then
      sed -i 's|^Icon=.*|Icon=kitty|' "$DESKTOP_DEST"
    fi

    echo "kitty icon applied"
    ;;

  *)
    echo "error: unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac
