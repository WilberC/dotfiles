<h2 align="center">wilberc/dotfiles</h2>

## Prerequisites

- [GNU Stow](https://www.gnu.org/software/stow/)

## Packages

| Package  | Contents                                          | Platform     |
|----------|---------------------------------------------------|--------------|
| `git`    | `.gitconfig`, global `.gitignore`                 | All          |
| `shared` | Fish, Ghostty, tmux, Zed, lazygit, mise, Codex, scripts | All       |
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
stow --no-folding git shared

# Pick one OS package
stow --no-folding -d os -t ~ linux   # Linux
stow --no-folding -d os -t ~ osx     # macOS
stow --no-folding -d os -t ~ wsl2    # WSL2
```

> **Stow flags:** `--no-folding` keeps shared directories such as
> `~/.config/fish/conf.d` as real directories so files from `shared` and the
> selected OS package can coexist. `-d <dir>` sets the package directory
> (where Stow looks for packages), while `-t <target>` sets where symlinks are
> created. OS packages need `-t ~` explicitly because `-d os` shifts Stow's
> default target away from `~`.

## Agent skills (moved)

Agent skills and the `sync-skills` script now live in [dotfiles-skills](https://github.com/WilberC/dotfiles-skills). If you previously had skills linked from this repo (`shared/.agents/skills`), migrate with:

```bash
git clone git@github.com:WilberC/dotfiles-skills.git ~/dotfiles-skills
~/dotfiles-skills/install.sh   # links sync-skills and relinks existing skills
```

## Repository structure

```
dotfiles/
├── git/                  # .gitconfig, global .gitignore
├── shared/               # Fish, Ghostty, Zed, lazygit, mise, scripts
├── os/                   # OS-specific packages (linux, osx, wsl2)
├── scripts/              # Setup scripts (not stowed)
├── templates/            # Templates copied to machine-local configs
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

**Private SSH config groups** (homelab/Proxmox hosts, etc.) work the same way: any `shared/.config/ssh/configs/<group>.conf.example` defines a group whose real `<group>.conf` holds actual IPs and is gitignored (this repo is public), synced through a 1Password Secure Note instead. Currently just `homelab` — see `homelab.conf.example` for the format.

```bash
bash scripts/ssh-config.sh              # interactive: pick push/pull and group(s) via fzf
bash scripts/ssh-config.sh push homelab # or drive it directly / from another script
bash scripts/ssh-config.sh pull homelab
```

See [docs/homelab-ssh.md](docs/homelab-ssh.md) for the full picture: the 1Password agent relay, authorizing keys on new hosts (including LXC containers, which need a different path than everything else), and the Proxmox-side tooling.

### WSL localhost access

On a Windows machine running WSL2, enable mirrored networking once per Windows
user account so services listening on Windows `localhost` are also available at
`localhost` from WSL:

```bash
powershell.exe -ExecutionPolicy Bypass -File "$(wslpath -w "$PWD/scripts/setup-wsl-mirrored-networking.ps1")"
```

The script preserves other `.wslconfig` settings and does not close your
terminal. Restart WSL when convenient to apply the change:

```powershell
wsl --shutdown
```

## Updating configs

After editing a shared config file, restow it with the repository helper:

```bash
bash scripts/stow-shared.sh
```

The helper uses `--no-folding`, preserving directories that contain links from
both `shared` and an OS-specific package.

## MCP servers

Install MCP servers with `codex mcp add <name> -- <command>`.

| Server | Install |
| --- | --- |
| OpenPencil | `codex mcp add open-pencil -- openpencil-mcp` |

## Codex

The preferred TUI status line is versioned as
`templates/codex/dotfiles.config.toml`. The manual setup helper copies it to
`~/.codex/dotfiles.config.toml`; it is intentionally outside `shared`, so Stow
does not link the mutable profile back into this repository. Codex can safely
append machine-local project trust to the copied profile without dirtying the
dotfiles worktree.

Codex is not assumed to be installed during bootstrap. After installing Codex,
create or migrate the profile manually with:

```bash
bash scripts/setup-codex-profile.sh
```

The command preserves an existing local profile. Changes made later to the
template are not applied automatically, avoiding overwrites of machine-local
settings.

The regular shell alias starts Codex without this optional profile. Activate it
explicitly when needed:

```bash
codex -p dotfiles
```

See [templates/codex/README.md](templates/codex/README.md) for installation,
migration, update, and maintenance instructions.

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

## SFTP directory links

From a Fish shell on a remote SSH host, run `sfh` to copy an SFTP URL for the
current directory to the local clipboard and print a clickable link. See the
[sftp-here guide](docs/sftp-here.md) for Windows and macOS client setup,
connection overrides, and troubleshooting.

> **Note:** Branch `chore/generalize-gitconfig` has a version of `.gitconfig` with no user-specific data (no name, email, or signing key). `gpgsign` is disabled there. To use it, configure git user globally after stowing:
> ```bash
> git config --global user.name "Your Name"
> git config --global user.email "you@example.com"
> ```
