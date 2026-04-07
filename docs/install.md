# Installing on a New Machine

## Overview

Setup runs in two phases:

1. **Personal** — `dotfiles/install.sh` sets up the base environment
2. **Work** — `dotfiles-work/install.sh` layers work configs on top (called automatically by step 1)

## Quick start

```sh
git clone https://github.com/WilberC/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
```

> Before running, make sure 1Password is open and the SSH agent is enabled — it is required to clone `dotfiles-work` and to verify SSH connections during install.

## What `install.sh` does

### 1. Detect OS

Identifies the platform (`osx`, `linux`, or `wsl2`) to apply the right configs and package steps.

### 2. Install prerequisites

**macOS:**
- Installs Xcode CLI tools if missing (and exits early — re-run after they finish)
- Installs Homebrew if missing
- Upgrades git to latest via Homebrew
- Installs `stow`

**Linux / WSL2:**
- Runs `apt-get update` (package lists only — upgrade is intentionally skipped to keep re-runs fast)
- Adds the git PPA for the latest git version
- Installs `git` and `stow`

> Run `sudo apt-get upgrade` manually before running `install.sh` if you want to upgrade system packages first.

### 3. Stow personal dotfiles

Symlinks configs into `~` for: `git`, `zsh`, `shared`, and the platform directory (`osx`, `linux`, or `wsl2`).

### 4. Install packages

**macOS** — via Homebrew:
```sh
brew bundle --file=shared/Brewfile
```

**Linux / WSL2** — via apt, after configuring official apt repos for `gh`, `lazygit`, `mise`, and `eza`:
```sh
# packages listed in shared/Aptfile
apt-get install ...
```

Note: `git-delta` and `difftastic` have no apt package — they are listed in the post-install hints for manual install. See [tools-and-commands.md](tools-and-commands.md) for the full package list.

### 5. Verify personal setup

- Prints the resolved `user.name` and `user.email` from git config
- Tests GitHub SSH — **aborts if it fails**, since the next step needs it to clone `dotfiles-work`

### 6. Clone and install dotfiles-work

Clones `git@github.com:WilberC/dotfiles-work.git` into `~/dotfiles/dotfiles-work` and runs its `install.sh`, which:
- Stows all company packages
- Regenerates `~/.config/gitconfig/work`
- Creates `~/Projects/Work/<Company>` for each company package
- Verifies each company's git identity and SSH connection

### 7. Create project folders

Creates the base project directory structure:
- `~/Projects/Personal/`
- `~/Projects/Others/`

`~/Projects/Work/<Company>` dirs are created by `dotfiles-work/install.sh` (step 6).

### 8. Post-install hints

Prints a checklist for the remaining manual steps:
- `mise install` — set up tool versions
- `gh auth login` — sign into GitHub CLI

## After install

| Task | Command |
|------|---------|
| Refresh symlinks after a config change | `stow --restow <package>` |
| Add a new work company | `bash ~/dotfiles/dotfiles-work/add-company.sh` |
| Regenerate git work routing | `bash ~/dotfiles/dotfiles-work/refresh.sh` |
