# Tech Debt

## projects.conf — source from 1Password

`projects.conf` defines the project directory structure created during install.
It currently lives in the repo, but it contains personal/work structure that
should be private and machine-specific.

**Goal:** store `projects.conf` in 1Password and have `install.sh` fetch it
automatically. If the file is missing, the script should detect it, prompt the
user to authenticate with 1Password, and pull the file before continuing.

## Per-project `.env` — source from 1Password

Project-specific secrets (API keys, tokens, DB URLs) currently live in plain
`.env` files or are set manually. These should be stored in 1Password and
injected per-project at shell/session init.

**Goal:** use `op run` or `op inject` to populate `.env` per project
automatically. Integration point could be a shell hook (e.g. `direnv` +
`op inject`) so secrets load when entering a project directory without ever
touching disk.
