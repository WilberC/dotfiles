# Zsh Config

The zsh configuration is managed by the [zsh4humans](https://github.com/romkatv/zsh4humans) framework.
`.zshrc` initializes z4h, then sources every `*.zsh` file in `~/.config/zsh/config.d/` in lexicographic order.

## File layout

```
zsh/
  .zshenv                          # Sets ZDOTDIR early
  .zshrc                           # z4h init + sources config.d/
  .config/zsh/
    config.d/                      # Sourced in order at shell startup (shared)
      00-env.zsh
      40-plugins.zsh
      80-keybindings.zsh
      98-aliases.zsh
      99-commands.zsh
    commands/                      # Sourced by 99-commands.zsh
      git.zsh
      network.zsh

osx/.config/zsh/config.d/30-dependencies.zsh   # macOS
linux/.config/zsh/config.d/30-dependencies.zsh # Linux
wsl2/.config/zsh/config.d/30-dependencies.zsh  # WSL2
```

## Load order

| File | Purpose |
|------|---------|
| `00-env.zsh` | PATH additions and environment variables set early |
| `30-dependencies.zsh` | OS-specific setup (1Password SSH socket, Homebrew, libpq) — one copy per platform (`osx/`, `linux/`, `wsl2/`) |
| `40-plugins.zsh` | Tool bootstrapping: installs `mise` and `cargo` if missing, then activates them |
| `80-keybindings.zsh` | Custom key bindings (ZLE) |
| `98-aliases.zsh` | Shell options, file-extension aliases, and command aliases (`ls`, `ll`, `lg`, etc.) |
| `99-commands.zsh` | Sources all files in `commands/` (`git.zsh`, `network.zsh`) |

## Adding a new config file

1. Pick a number in the right range for when it should run.
2. Name it `NN-description.zsh` and place it in `zsh/.config/zsh/config.d/`.
3. If it's OS-specific, put it under `osx/.config/zsh/config.d/` (or `linux/`, `wsl2/`) instead.
4. Restow: `stow -R zsh` (and the platform stow if needed).

## Adding a new shell function or alias

- **Aliases and options** → `zsh/.config/zsh/config.d/98-aliases.zsh`
- **Functions** → add a new file under `zsh/.config/zsh/commands/` (e.g., `commands/docker.zsh`). It will be auto-sourced by `99-commands.zsh`.

## Platform split for `30-dependencies.zsh`

Each platform stow package provides its own copy:

| File | What it sets up |
|------|----------------|
| `osx/.config/zsh/config.d/30-dependencies.zsh` | macOS: 1Password SSH socket (`~/Library/…`), Homebrew paths, libpq |
| `linux/.config/zsh/config.d/30-dependencies.zsh` | Linux: 1Password SSH socket, Homebrew paths |
| `wsl2/.config/zsh/config.d/30-dependencies.zsh` | WSL2: Windows 1Password socket path (`/mnt/…`) |

Only one of these lands in `~/.config/zsh/config.d/` at a time depending on which platform you stow.

## Related docs

- [Git config structure](git-config-structure.md)
- [Tools and commands](tools-and-commands.md)
