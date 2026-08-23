# kitty custom icon (macOS)

The custom dark icon is applied and kept in place by two complementary mechanisms:

1. **`set-kitty-icon.sh`** — sets the icon via `NSWorkspace.setIcon` (the same API Finder uses for "Get Info → paste icon"). The icon is stored as a Finder custom-icon extended attribute on the `.app` directory; the bundle's signed content is never modified, so no codesign step is needed. On first run, macOS will prompt for **App Management** permission — click Allow.

2. **LaunchAgent** (`com.user.kitty-icon.plist`) — watches `/Applications` (not `kitty.app` directly, because the inode is destroyed on brew upgrade) and fires the script with `--watch`. Install/reload it by running `set-kitty-icon.sh --install`.

3. **brew hook** in `aliases.zsh` — runs the script after `brew upgrade` / `brew install` / `brew reinstall kitty`. This is the *primary* re-apply mechanism.

Log: `~/Library/Logs/kitty-icon.log` — each invocation is prefixed with a timestamp header (`--- launchd …` or `--- brew hook …`).
