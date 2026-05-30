# Tech Debt

## Per-project `.env` — source from 1Password

Project-specific secrets (API keys, tokens, DB URLs) currently live in plain
`.env` files or are set manually. These should be stored in 1Password and
injected per-project at shell/session init.

**Goal:** use `op run` or `op inject` to populate `.env` per project
automatically. Integration point could be a shell hook (e.g. `direnv` +
`op inject`) so secrets load when entering a project directory without ever
touching disk.
