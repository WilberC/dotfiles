# Codex user configuration template

This directory contains the versioned TUI settings added to Codex's normal user
configuration. The live `config.toml` remains machine-local so Codex can store
project trust and other local settings without modifying this repository.

## Apply manually

This template is intended to be applied by an AI agent or carefully by hand.
Do not add it to `install.sh` and do not create a named Codex profile.

1. Read `tui.config.toml` and the live `${CODEX_HOME:-~/.codex}/config.toml`.
2. Create the live config with permissions `0600` if it does not exist.
3. If `[tui]` is absent, add the complete template section.
4. If `[tui]` exists, update only the keys present in the template. Preserve
   any other keys in that section.
5. Preserve all other tables and values, especially `[projects]`, MCP servers,
   hooks, application state, and credentials.
6. Validate the resulting TOML and confirm that the template keys match.

This is deliberately a manual post-installation step. The template lives
outside `shared`, so GNU Stow never links the mutable config into the
repository.

## Use the configuration

Run `codex` normally. No `--profile` option is required because the status line
is part of `~/.codex/config.toml`.

## Update the template

To roll out a template change, compare it with the section in the live config
and apply only the portable settings:

```bash
diff -u templates/codex/tui.config.toml ~/.codex/config.toml
```

Do not copy `[projects]`, plugin state, application state, credentials, or
other machine-local values back into the template.
