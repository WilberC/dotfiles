# Zsh Config README — Implementation

Place this file at `zsh/.config/zsh/README.md` (stowed to `~/.config/zsh/README.md`).

---

## Proposed content

````markdown
# Zsh Config

This directory holds the zsh configuration loaded by `.zshrc` via the
[zsh4humans](https://github.com/romkatv/zsh4humans) framework.

## Load order

Files in `config.d/` are sourced in lexicographic order at shell startup.
The numeric prefix controls the order — leave gaps between numbers so new
files can be inserted without renaming existing ones.

| File                  | Purpose                                              |
|-----------------------|------------------------------------------------------|
| `00-env.zsh`          | PATH additions and environment variables set early   |
| `30-dependencies.zsh` | OS-specific setup (1Password SSH socket, Homebrew, libpq) — **one copy per platform** (`osx/`, `linux/`, `wsl2/`) |
| `40-plugins.zsh`      | Tool bootstrapping: installs `mise` and `cargo` if missing, then activates them |
| `80-keybindings.zsh`  | Custom key bindings (zsh line editor / ZLE)          |
| `99-commands.zsh`     | Aliases and shell functions                          |

## Adding a new file

1. Pick a number in the right range for when it should run.
2. Name it `NN-description.zsh`.
3. If it's OS-specific, put it in `osx/.config/zsh/config.d/` (or `linux/`, `wsl2/`) instead of `zsh/.config/zsh/config.d/`.

## Platform split

`30-dependencies.zsh` exists in three places:

```
osx/.config/zsh/config.d/30-dependencies.zsh    ← macOS: 1Password socket, Homebrew
linux/.config/zsh/config.d/30-dependencies.zsh  ← Linux
wsl2/.config/zsh/config.d/30-dependencies.zsh   ← WSL2: Windows 1Password socket path
```

All other `config.d/` files live under `zsh/` and are shared across platforms.
````
