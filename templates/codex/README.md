# Codex profile template

This directory contains the versioned template for the optional Codex
`dotfiles` profile. The live profile must be a machine-local file so Codex can
store project trust and other local settings without modifying this repository.

## Install or migrate

From the repository root, run:

```bash
bash scripts/setup-codex-profile.sh
```

The script manages `$CODEX_HOME/dotfiles.config.toml`, defaulting to
`~/.codex/dotfiles.config.toml` when `CODEX_HOME` is unset.

- If the profile is missing, it copies `dotfiles.config.toml` from this
  directory with permissions `0600`.
- If the profile is an old symlink, it replaces the symlink with a local file
  while preserving its current contents.
- If a local profile already exists, it leaves it unchanged so machine-local
  project trust is not overwritten.

This is deliberately a manual post-installation step. Neither `install.sh` nor
`scripts/stow-shared.sh` invokes it because Codex is normally unavailable when
the dotfiles bootstrap runs. The template lives outside `shared`, so GNU Stow
never links the mutable profile into the repository.

## Use the profile

The regular `codex` shell alias starts Codex without a profile. Activate this
optional profile explicitly when needed:

```bash
codex -p dotfiles
```

Without `-p dotfiles`, Codex uses only `~/.codex/config.toml`.

## Update the template

Edits to the template are not copied over an existing local profile. To roll
out a template change, compare both files and apply only the portable settings:

```bash
diff -u templates/codex/dotfiles.config.toml ~/.codex/dotfiles.config.toml
```

Do not copy `[projects]`, plugin state, application state, credentials, or
other machine-local values back into the template.

After changing the setup behavior, validate both cases: a missing destination
and a destination that is a symlink. Keep `scripts/setup-codex-profile.sh`
idempotent so running it repeatedly never overwrites a local profile.
