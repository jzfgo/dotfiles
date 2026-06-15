#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "error: this script should not be run as root or with sudo" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" >/dev/null && pwd)"
ICON_DARK_ICNS="$SCRIPT_DIR/icon/kitty-dark.icns"
ICON_DARK_PNG="$SCRIPT_DIR/icon/kitty-dark.png"
PLIST_SRC="$SCRIPT_DIR/com.user.kitty-icon.plist"
PLIST_LABEL="com.user.kitty-icon"
PLIST_DEST="$HOME/Library/LaunchAgents/$PLIST_LABEL.plist"

_install_launchagent() {
  if [[ ! -f "$PLIST_SRC" ]]; then
    echo "error: plist source file not found at $PLIST_SRC" >&2
    exit 1
  fi
  mkdir -p "$HOME/Library/LaunchAgents"
  rm -f "$PLIST_DEST"
  cp -f "$PLIST_SRC" "$PLIST_DEST"
  chmod 644 "$PLIST_DEST"
  launchctl bootout "gui/$(id -u)/$PLIST_LABEL" 2>/dev/null || true
  launchctl bootstrap "gui/$(id -u)" "$PLIST_DEST"
  echo "LaunchAgent installed — icon will be re-applied automatically after kitty updates"
}

case "$(uname -s)" in
  Darwin)
    KITTY_APP="/Applications/kitty.app"

    if [[ ! -f "$ICON_DARK_ICNS" ]]; then
      echo "error: source icon not found at $ICON_DARK_ICNS" >&2
      exit 1
    fi

    if [[ "${1:-}" == "--watch" ]]; then
      # WatchPaths fires while brew is mid-install and the bundle is temporarily
      # absent; retry until it appears or we give up.
      for i in {1..10}; do
        [[ -d "$KITTY_APP" ]] && break
        if [[ $i -eq 10 ]]; then
          echo "error: kitty not found at $KITTY_APP" >&2
          exit 1
        fi
        sleep 2
      done
    elif [[ ! -d "$KITTY_APP" ]]; then
      echo "error: kitty not found at $KITTY_APP" >&2
      exit 1
    fi

    # Apply the custom icon via the same NSWorkspace API that Finder uses when
    # you paste an icon in Get Info. The icon is stored as a Finder custom-icon
    # extended attribute on the .app directory — the bundle's signed content is
    # never touched, so no codesign step is needed.
    # macOS will prompt for App Management permission on the first run if needed.
    if ! osascript \
        -e 'use framework "AppKit"' \
        -e "set img to current application's NSImage's alloc()'s initWithContentsOfFile:\"$ICON_DARK_ICNS\"" \
        -e "current application's NSWorkspace's sharedWorkspace()'s setIcon:img forFile:\"$KITTY_APP\" options:0"; then
      echo "error: could not set icon — if prompted, grant App Management permission in System Settings → Privacy & Security, then re-run this script" >&2
      exit 1
    fi

    # Notify Launch Services and the Dock so the new icon appears immediately.
    touch "$KITTY_APP"
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
      -f "$KITTY_APP" || true

    # Skip Dock restart in --watch mode to avoid disruptive screen flickering
    # while the user is working.
    if [[ "${1:-}" != "--watch" ]]; then
      killall Dock || true
    fi

    echo "kitty icon applied — you may need to relaunch kitty for the change to appear"

    if [[ "${1:-}" == "--install" ]]; then
      _install_launchagent
    fi
    ;;

  Linux)
    if [[ ! -f "$ICON_DARK_PNG" ]]; then
      echo "error: source icon not found at $ICON_DARK_PNG" >&2
      exit 1
    fi

    HICOLOR_DIR="$HOME/.local/share/icons/hicolor"
    ICON_DEST="$HICOLOR_DIR/256x256/apps"
    mkdir -p "$ICON_DEST"
    cp "$ICON_DARK_PNG" "$ICON_DEST/kitty.png"

    if command -v gtk-update-icon-cache &>/dev/null; then
      gtk-update-icon-cache --force --quiet --ignore-theme-index "$HICOLOR_DIR" || true
    fi

    # Create a user-level .desktop override only when the system entry uses a
    # non-standard icon path. Most kitty packages already ship Icon=kitty, so
    # in that case the hicolor entry above is sufficient and no override is needed.
    DESKTOP_DEST="$HOME/.local/share/applications/kitty.desktop"
    DESKTOP_SRC=""
    IFS=: read -ra _xdg_dirs < <(printf '%s\n' "${XDG_DATA_DIRS:-/usr/local/share:/usr/share}")
    for _dir in "${_xdg_dirs[@]}"; do
      [[ -d "$_dir" ]] || continue
      candidate="$_dir/applications/kitty.desktop"
      if [[ -f "$candidate" ]]; then
        if [[ "$candidate" -ef "$DESKTOP_DEST" ]]; then
          continue
        fi
        DESKTOP_SRC="$candidate"
        break
      fi
    done
    if [[ -n "$DESKTOP_SRC" ]]; then
      if ! grep -q '^[[:space:]]*Icon[[:space:]]*=[[:space:]]*kitty$' "$DESKTOP_SRC"; then
        if [[ ! -f "$DESKTOP_DEST" ]] || grep -q '# Modified by set-kitty-icon.sh' "$DESKTOP_DEST"; then
          mkdir -p "$(dirname "$DESKTOP_DEST")"
          cp "$DESKTOP_SRC" "$DESKTOP_DEST"
          chmod +w "$DESKTOP_DEST"
          if grep -q '^[[:space:]]*Icon[[:space:]]*=' "$DESKTOP_DEST"; then
            sed -i 's|^[[:space:]]*Icon[[:space:]]*=.*|Icon=kitty|' "$DESKTOP_DEST"
          else
            sed -i '/^\[Desktop Entry\][[:space:]]*$/a Icon=kitty' "$DESKTOP_DEST"
          fi
          echo "# Modified by set-kitty-icon.sh" >> "$DESKTOP_DEST"
        fi
      else
        if [[ -f "$DESKTOP_DEST" ]] && grep -q '# Modified by set-kitty-icon.sh' "$DESKTOP_DEST"; then
          rm "$DESKTOP_DEST"
        fi
      fi
    fi

    if command -v update-desktop-database &>/dev/null; then
      update-desktop-database "$HOME/.local/share/applications" || true
    fi

    echo "kitty icon applied"
    ;;

  *)
    echo "error: unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac
