# Scripts Discoverability — Where They Are and What to Do

## Where the scripts actually are

The improvements doc mentions a top-level `scripts/` directory, but that doesn't exist. The scripts live here:

```
shared/scripts/until_failure
shared/scripts/install_bfg
```

Because they're under `shared/`, stow puts them at:

```
~/.config/../../scripts/   ← NO — wrong assumption
```

Wait — `shared/` mirrors the home directory. So stow maps `shared/scripts/` → `~/scripts/`. That means the scripts land at `~/scripts/until_failure` and `~/scripts/install_bfg` on your machine.

**`~/scripts/` is not in PATH.** That's why they're undiscoverable — you can't just type `until_failure` in a terminal.

## What's being proposed

### Option A: Move scripts into `shared/.local/bin/`

`00-env.zsh` already adds `~/.local/bin` to PATH:

```zsh
path=(
  $path
  ~/.local/bin
)
```

So if you move the scripts to `shared/.local/bin/`, stow puts them at `~/.local/bin/until_failure` and `~/.local/bin/install_bfg`, and they're immediately available in every shell session. No PATH changes needed.

```
shared/
  .local/
    bin/
      until_failure    ← move here
      install_bfg      ← move here
  scripts/             ← remove this directory
```

### Option B: Add `~/scripts/` to PATH

In `zsh/.config/zsh/config.d/00-env.zsh`, add:

```zsh
path=(
  $path
  ~/.local/bin
  ~/scripts          # ← add this
)
```

Keeps the current file location, just makes it reachable.

## Recommendation

**Option A** is cleaner. `~/.local/bin` is the standard Unix location for user-local executables. It's already in PATH. Moving there costs nothing and follows convention. Option B works too but adds a non-standard directory to PATH for the same result.

## What the scripts do

- `until_failure` — runs a command repeatedly until it exits non-zero (useful for flaky test debugging)
- `install_bfg` — downloads and installs [BFG Repo Cleaner](https://rtyley.github.io/bfg-repo-cleaner/) for scrubbing git history
