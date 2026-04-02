# Bootstrap Script — Implementation Plan

## Goal

A single `install.sh` at the repo root that sets up a new machine end-to-end with no manual steps.

## Steps

### 1. Detect OS

```bash
case "$(uname -s)" in
  Darwin) PLATFORM="osx" ;;
  Linux)
    grep -qi microsoft /proc/version && PLATFORM="wsl2" || PLATFORM="linux"
    ;;
  *) echo "Unsupported OS"; exit 1 ;;
esac
```

### 2. Install prerequisites

**macOS:**
- Check for Xcode CLI tools (`xcode-select -p`), install if missing
- Check for Homebrew, install if missing
- `brew install stow`

**Linux/WSL2:**
- `sudo apt-get install -y stow`

### 3. Stow the right directories

Always stow:
- `git`
- `zsh`
- `shared`

Then stow the platform directory: `osx`, `linux`, or `wsl2`.

```bash
cd "$(dirname "$0")"
for dir in git zsh shared "$PLATFORM"; do
  stow --restow "$dir"
done
```

### 4. Install packages

- **macOS**: `brew bundle --file=osx/Brewfile` (once Brewfile exists — see point 2)
- **Linux**: `xargs sudo apt-get install -y < linux/Aptfile`
- **WSL2**: same as Linux

### 5. Post-install hints

Print a short checklist reminding the user to:
- Open 1Password and enable the SSH agent
- Sign into GitHub (`gh auth login`)
- Set up `mise` tool versions

## File layout

```
dotfiles/
  install.sh        ← new entry point
  osx/Brewfile      ← new (see point 2)
  linux/Aptfile     ← already exists
```

## Order of implementation

1. Write `install.sh` with OS detection and stow logic (no package installs yet)
2. Add Brewfile (point 2)
3. Wire package install into `install.sh`
4. Add post-install hint output
