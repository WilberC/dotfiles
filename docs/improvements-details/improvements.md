# High-Level Improvements

Areas identified for improvement, ordered roughly by impact.

---

## 1. Bootstrap Script

There's no single entry point to set up a new machine. Currently requires manually running `stow` for each directory and knowing which ones apply to your platform. A bootstrap script (e.g. `install.sh`) would:
- Detect the OS automatically
- Run the right `stow` commands for that platform
- Install prerequisites (Homebrew, Stow, etc.) if missing

## 2. Package Management Parity

Linux has an `Aptfile` listing packages to install, but macOS has no equivalent `Brewfile`. This means the macOS tool stack (eza, lazygit, delta, difft, ghostty, zed, etc.) isn't declaratively tracked anywhere in the repo.

## 3. Secrets and SSH Key Inventory

Public SSH keys live in `shared/.config/ssh/pubs/`, but there's no documentation of what key is used where, when they were created, or what their fingerprints are. Easy to lose track of which keys are still active, especially across multiple accounts (personal, Outcode, Azure).

## 4. No Shared Tool Version Pinning

`mise.toml` is globally gitignored, so there's no record of which tool versions are in use. If reinstalling on a new machine, you'd have no reference for what versions to install.

## 5. Work/Personal Separation

The repo mixes personal and work (Outcode) configuration (git accounts, SSH keys, Azure SSH config). Sensitive work-related config being in a personal public dotfiles repo is a potential concern — worth evaluating what should be private.

## 6. Zsh Config Has No README

The `zsh/.config/zsh/config.d/` loading order and naming convention (00-, 30-, 40-, etc.) is not documented anywhere. Adding a short note makes it easier to extend without breaking load order.

## 7. Scripts Are Undiscoverable

`scripts/` contains useful utilities (`until_failure`, `install_bfg`) but they're not in PATH and not mentioned anywhere except implicitly. Either add `scripts/` to PATH or move them to `shared/.local/bin/`.
