# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Installation

This repo uses [GNU Stow](https://www.gnu.org/software/stow/) to symlink configs into the home directory. Each top-level directory mirrors the home directory structure.

```sh
# Install a specific platform/config set
stow zsh && stow git && stow osx   # macOS
stow zsh && stow git && stow linux # Linux
stow zsh && stow git && stow wsl2  # WSL2

# Restow after changes (refresh symlinks)
stow -R zsh

# Also stow shared configs
stow shared

# Stow AI agent global skills
stow ai-skills
```

## Repository Structure

- `git/` — Git config (`.gitconfig`, `.global_gitignore`)
- `zsh/` — Zsh shell config using the [zsh4humans](https://github.com/romkatv/zsh4humans) framework
- `osx/` — macOS-specific configs (SSH agent via 1Password, Homebrew paths)
- `linux/` — Linux-specific configs
- `wsl2/` — WSL2-specific configs (Windows 1Password SSH signing path)
- `shared/` — Platform-agnostic configs symlinked on all platforms:
  - `.config/gitconfig/` — Git identity and per-directory account switching
  - `.config/ssh/configs/` — Modular SSH host configs (GitHub, Azure, personal server)
  - `.config/ssh/pubs/` — Public SSH keys (no private keys tracked)
  - `.config/lazygit/` — Lazygit with `difft` + `delta`
  - `.config/ghostty/` — Ghostty terminal
  - `.config/zed/` — Zed editor
- `scripts/` — Utility scripts (`until_failure`) — stowed to `~/scripts/`, aliased in `98-aliases.zsh`
- `ai-skills/` — Global AI agent skills. Source of truth is `.agents/skills/`. Each agent dir (`.claude/`, `.qwen/`, `.kilocode/`) has a `skills` symlink pointing to `../.agents/skills` — add a skill once, all agents pick it up automatically. See `docs/tools-and-commands.md` for the workflow.

## Agent-Specific Configuration

Each AI agent has its own configuration directory:
- `.claude/` — Claude Code settings and prompts
- `.qwen/` — Qwen Code settings (see [`docs/qwen-config.md`](docs/qwen-config.md))
- `.kilocode/` — Kilocode settings

See [`ai-skills/.qwen/example.settings.json`](ai-skills/.qwen/example.settings.json) for an example Qwen configuration.

## Key Architecture Decisions

**Platform split**: OS-specific files live in `osx/`, `linux/`, `wsl2/`. Anything that works everywhere goes in `shared/` or `zsh/`.

**Zsh config loading order** (`.config/zsh/config.d/`):
- `00-env.zsh` — PATH additions
- `30-dependencies.zsh` — OS-specific (1Password SSH socket, Homebrew, libpq)
- `40-plugins.zsh` — Tool bootstrapping (mise, cargo)
- `80-keybindings.zsh` — Custom key bindings
- `99-commands.zsh` — Aliases and shell functions

**Git accounts**: Conditional includes in `shared/.config/gitconfig/main_config` switch between personal and work (Outcode) identities based on the working directory path.

**SSH via 1Password**: All platforms use the 1Password SSH agent for authentication and SSH-format GPG signing. The socket path differs per OS.

- If there is an util command tool or something that should be noted add to docs/tools-and-commands.md so is easy to know what tools are available. Only add the necessary ones so we keep it clean and only with the needed one.

## Maintaining the `help` command

`zsh/.config/zsh/commands/help.zsh` documents all custom aliases and functions. Keep it in sync when adding/removing commands:

- **New alias in `98-aliases.zsh`** → add a `_help_cmd` line under the right section in the `help` listing, and a `case` block if it needs detailed help.
- **New function in `commands/*.zsh`** → same as above.
- **Removed command** → remove its `_help_cmd` line and `case` block.
- Sections: Navigation, File Operations, Directory Listing, Git, Secrets, Development, AI Assistants, Network. Add a new `_help_section` if a command doesn't fit any existing one.
- Only document custom/non-obvious commands. External tools (gh, bfg, delta…) have their own `--help`.

- ALL CHANGES MUST BE JUST INSIDE THIS FOLDER, NEVER OUTSIDE IT.
