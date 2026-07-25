<h2 align="center">wilberc/dotfiles</h2>

## Prerequisites

- [GNU Stow](https://www.gnu.org/software/stow/)

## Packages

| Package  | Contents                                          | Platform     |
|----------|---------------------------------------------------|--------------|
| `git`    | `.gitconfig`, global `.gitignore`                 | All          |
| `shared` | Fish, Ghostty, tmux, Zed, lazygit, mise, amp, scripts | All       |
| `os/linux`  | OS-specific git config, SSH, local bin         | Linux        |
| `os/osx`    | OS-specific git config, SSH, LaunchAgents      | macOS        |
| `os/wsl2`   | OS-specific git config, 1Password socket, Zsh  | WSL2         |

## Installation

```bash
git clone git@github.com:wilberc/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Stow the packages you need:

```bash
# All platforms
stow git shared

# Pick one OS package
stow -d os -t ~ linux   # Linux
stow -d os -t ~ osx     # macOS
stow -d os -t ~ wsl2    # WSL2
```

> **Stow flags:** `-d <dir>` sets the package directory (where stow looks for packages). `-t <target>` sets where symlinks are created. OS packages need `-t ~` explicitly because `-d os` shifts stow's default target away from `~`.

## Agent skills (moved)

Agent skills and the `sync-skills` script now live in [dotfiles-skills](https://github.com/WilberC/dotfiles-skills). If you previously had skills linked from this repo (`shared/.agents/skills`), migrate with:

```bash
git clone git@github.com:WilberC/dotfiles-skills.git ~/dotfiles-skills
~/dotfiles-skills/install.sh   # links sync-skills and relinks existing skills
```

## Repository structure

```
dotfiles/
├── git/          # .gitconfig, global .gitignore
├── shared/       # Fish, Ghostty, Zed, lazygit, mise, scripts
├── os/           # OS-specific packages (linux, osx, wsl2)
├── scripts/              # Setup scripts (not stowed)
├── docs/                 # Notes and tech debt
├── projects.conf.example # Template for project directory layout (see below)
└── install.sh            # Bootstrap script
```

## install.sh

Run `./install.sh` to bootstrap a new machine. The script:

1. **Detects** the OS (WSL2, Linux, macOS)
2. **Prompts** to confirm or override the detected platform
3. **Installs dependencies** per platform:
   - `osx` — Xcode CLT → Homebrew → stow via `brew`
   - `linux` / `wsl2` — `apt update && upgrade` → stow via `apt`
4. **Stows** `git` and `shared` (all platforms)
5. **Stows** the OS package from `os/<platform>`

Idempotent — safe to re-run, skips already-installed tools.

**Project directories** are created from `projects.conf` during install. The file is private and stored in 1Password — `setup-dirs.sh` fetches it automatically if missing. See `projects.conf.example` for the format and first-time setup instructions.

To run that step alone:

```bash
bash scripts/setup-dirs.sh
```

## Updating configs

After editing a config file, restow its package:

```bash
stow -R shared
```

## tmux

tmux is an opt-in terminal multiplexer. Its configuration lives at
`~/.config/tmux/tmux.conf` after stowing `shared`. Start it manually with:

```bash
tmux
```

To test the repository configuration without stowing it first:

```bash
tmux -f ~/dotfiles/shared/.config/tmux/tmux.conf
```

The config keeps new panes in the current directory. With the tmux prefix
(`Ctrl-b`), use `|` or `-` to split, `h`/`j`/`k`/`l` to move between panes, and
`H`/`J`/`K`/`L` to resize them.

> **Note:** Branch `chore/generalize-gitconfig` has a version of `.gitconfig` with no user-specific data (no name, email, or signing key). `gpgsign` is disabled there. To use it, configure git user globally after stowing:
> ```bash
> git config --global user.name "Your Name"
> git config --global user.email "you@example.com"
> ```
