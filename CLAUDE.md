# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Deployment

This repo uses **GNU Stow**. Running `stow .` from the repo root symlinks all tracked files to `$HOME`, mirroring the directory structure exactly. `.stowrc` configures Stow to ignore `.stowrc`, `.DS_Store`, and `power-management.md`.

```bash
# Deploy all dotfiles
stow .

# Re-deploy after adding new files
stow -R .
```

After a fresh clone, initialize submodules:

```bash
git submodule update --init --recursive
```

Submodules: `powerlevel10k` (theme), `zsh-nvm` (plugin), `cheat/cheatsheets` (community cheat sheets).

## Platform split

The repo targets **macOS** (primary) and **Linux** (Hyprland/Wayland). Platform-specific config is loaded conditionally:

- **kitty**: `kitty.conf` sources `macos.conf` or `linux.conf` for OS-specific keybindings
- **git**: `.gitconfig` includes `~/.gitconfig.macos` and `~/.gitconfig.linux` (machine-local, not tracked)
- **Hyprland** (`~/.config/hypr/`): Linux-only; sources a machine-local `~/.config/hypr/local.conf` (not tracked) for per-machine overrides like monitor layout

## Shell (zsh / Oh My Zsh)

- **`.zshrc`** — loads Oh My Zsh with plugins: `direnv`, `eza`, `gcloud`, `zoxide`, `zsh-nvm`. Sources `~/.secrets` if present (not tracked).
- **`.zprofile`** — sets `$EDITOR`, `$PNPM_HOME`; sources `~/.zprofile.local` (not tracked).
- **`.oh-my-zsh/custom/`** — the place for all custom shell additions:
  - `aliases.zsh` — aliases + a `brew()` wrapper that re-applies the kitty custom icon after upgrades
  - `eza.zsh` — eza display configuration (replaces `ls`)
  - `yazi.zsh` — `y()` wrapper that changes the shell's CWD when exiting yazi

## Neovim

Config lives in `.config/nvim/` and is built on **NvChad** (loaded as a Lazy plugin). Structure:
- `init.lua` — entry point
- `lua/chadrc.lua` — NvChad overrides
- `lua/plugins/` — plugin declarations
- `lua/configs/` — per-plugin configuration
- `lua/mappings.lua`, `lua/options.lua`, `lua/autocmds.lua` — custom keymaps, options, autocommands

## kitty custom icon (macOS)

The custom dark icon is applied and kept in place by two complementary mechanisms:

1. **`set-kitty-icon.sh`** — the script that copies `.config/kitty/icon/kitty-dark.icns` over the app bundle's icon, removes `CFBundleIconName` from `Info.plist`, clears xattrs, and re-signs the bundle ad-hoc (`codesign --sign -`).

2. **LaunchAgent** (`com.user.kitty-icon.plist`) — watches `/Applications` (not `kitty.app` directly, because the inode is destroyed on brew upgrade) and fires the script with `--watch`. Install/reload it by running `set-kitty-icon.sh --install`.

3. **brew hook** in `aliases.zsh` — runs the script after `brew upgrade` / `brew upgrade kitty`. This is the *primary* re-apply mechanism because the LaunchAgent's bash process lacks the macOS **App Management TCC permission** needed to write into `/Applications` bundles; the terminal session has it.

Key constraint: **never route the icon write through launchd directly** — it will silently fail with a TCC block. The brew hook in the terminal context is the reliable path.

Log: `~/Library/Logs/kitty-icon.log` — each invocation is prefixed with a timestamp header (`--- launchd …` or `--- brew hook …`).

## Hyprland (Linux)

`~/.config/hypr/hyprland.conf` sources modular files from `~/.config/hypr/modules/`:

| File | Purpose |
|---|---|
| `monitors.conf` | Monitor layout |
| `my-programs.conf` | Default apps (`$terminal`, `$browser`, etc.) |
| `keybindings.conf` | All keybindings |
| `look-and-feel.conf` | Gaps, borders, animations |
| `autostart.conf` | Startup daemons |
| `env.conf` | Environment variables for Wayland/XDG |

Machine-specific overrides (monitor configs, local app paths) go in the untracked `~/.config/hypr/local.conf`.

Bar config is in `.config/waybar/` (JSONC + CSS). App launcher in `.config/rofi/`.
