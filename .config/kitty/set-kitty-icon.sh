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
    fi

    KITTY_APP="/Applications/kitty.app"

    [[ -d "$KITTY_APP" ]] || { echo "error: kitty not found at $KITTY_APP" >&2; exit 1; }

    # Use NSWorkspace API via osascript to set the icon as a Finder extended attribute.
    # This keeps the app bundle's sealed resources, code signature, entitlements, and
    # system permissions (Accessibility, Input Monitoring, etc.) fully intact.
    # WatchPaths can fire while Homebrew is mid-install, so retry for up to ~30s.
    for i in {1..10}; do
      if [[ -d "$KITTY_APP" ]] && \
         [[ "$(osascript \
           -e 'use framework "Cocoa"' \
           -e "set image to (current application's NSImage's alloc()'s initWithContentsOfFile:\"$ICON_DARK_ICNS\")" \
           -e "set workspace to (current application's NSWorkspace's sharedWorkspace())" \
           -e "workspace's setIcon:image forFile:\"$KITTY_APP\" options:0" \
           2>/dev/null)" == "true" ]]; then
        break
      fi
      [[ $i -eq 10 ]] && { echo "error: failed to set custom icon after retries" >&2; exit 1; }
      sleep 3
    done
    touch "$KITTY_APP"

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
