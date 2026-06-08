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

    # WatchPaths fires while Homebrew is mid-install and the bundle is temporarily
    # absent — no fast-fail here; let the retry loop handle the missing directory.
    ICNS_DEST="$KITTY_APP/Contents/Resources/kitty.icns"
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
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$KITTY_APP"

    killall Dock || true

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
    if [[ -n "$DESKTOP_SRC" ]] && [[ ! -f "$DESKTOP_DEST" || "$DESKTOP_SRC" -nt "$DESKTOP_DEST" ]]; then
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
