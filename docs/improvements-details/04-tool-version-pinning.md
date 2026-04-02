# Tool Version Pinning — What the Problem Is

## The idea

`mise` is a tool version manager (like `asdf`). It installs and switches between versions of things like Node, Python, Ruby, Go, Rust, etc. You configure which version to use by writing a `mise.toml` file.

Example `mise.toml`:

```toml
[tools]
node = "22.3.0"
python = "3.12.4"
go = "1.22.5"
```

When you run `mise install`, it installs exactly those versions. When you `cd` into a directory, `mise` automatically activates the right version.

## Why it's gitignored

The current `git/.global_gitignore` ignores `mise.toml`:

```
mise.toml
```

This means your tool versions are never committed anywhere. They only exist in your local `mise` state.

## The problem this causes

When you set up a new machine, you have no record of which versions to install. You'd have to remember (or guess) what you were using. Over time, subtle differences accumulate between machines.

## What you can do

There are two levels:

### Option A: Track a global `mise.toml` in the repo

Remove `mise.toml` from `.global_gitignore`, then create `shared/mise.toml` (or `zsh/mise.toml`) with your global tool versions. Stow it to `~/.config/mise/config.toml` (mise's global config path).

This is the most complete fix — your versions are pinned and reproducible.

### Option B: Just document the versions

Keep `mise.toml` gitignored, but add a comment block to `zsh/.config/zsh/config.d/40-plugins.zsh` noting which versions you care about. Lower friction, less precise.

### Option C: Leave it as-is

If you always want "latest stable" and don't care about exact parity between machines, the current setup is fine. `mise` will just install whatever's current at install time.

## Recommendation

Go with **Option A** if you work across multiple machines or want reproducibility. The global mise config path is `~/.config/mise/config.toml`, so create `shared/.config/mise/config.toml` and stow it.
