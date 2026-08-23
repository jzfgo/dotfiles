# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Deployment

This repo uses **GNU Stow**. Running `stow .` from the repo root symlinks all tracked files to `$HOME`, mirroring the directory structure exactly (`stow -R .` to re-deploy after adding files). `.stowrc` configures Stow to ignore `.stowrc`, `.DS_Store`, `power-management.md`, and `CLAUDE.md` files.

After a fresh clone, run `git submodule update --init --recursive`. Submodules: `powerlevel10k` (theme), `zsh-nvm` (plugin), `cheat/cheatsheets` (community cheat sheets).

## Platform split

The repo targets **macOS** (primary) and **Linux** (Hyprland/Wayland). Platform-specific config is loaded conditionally:

- **kitty**: `kitty.conf` sources `macos.conf` or `linux.conf` for OS-specific keybindings
- **git**: `.gitconfig` includes `~/.gitconfig.macos` and `~/.gitconfig.linux` (machine-local, not tracked)
- **Hyprland** (`~/.config/hypr/`): Linux-only; sources a machine-local `~/.config/hypr/local.conf` (not tracked) for per-machine overrides like monitor layout

## Shell (zsh / Oh My Zsh)

- **`.zshrc`** — loads Oh My Zsh with plugins: `direnv`, `eza`, `gcloud`, `zoxide`, `zsh-nvm`. Sources `~/.secrets` if present (not tracked).
- **`.zprofile`** — sets `$EDITOR`, `$PNPM_HOME`; sources `~/.zprofile.local` (not tracked).
- **`.oh-my-zsh/custom/`** — the place for all custom shell additions:
  - `aliases.zsh` — aliases + a `brew()` wrapper that re-applies the kitty custom icon after upgrades. Also sources `~/.zsh_aliases.local` (machine-local, not tracked) — host- or OS-specific aliases go there, never in tracked files
  - `eza.zsh` — eza display configuration (replaces `ls`)
  - `yazi.zsh` — `y()` wrapper that changes the shell's CWD when exiting yazi

## Nested guidance

Platform- and app-specific details live in nested CLAUDE.md files that load only when working under their directory: `.config/nvim/` (NvChad setup), `.config/kitty/` (macOS custom-icon mechanism), `.config/hypr/` (module layout and machine-local override contract).
