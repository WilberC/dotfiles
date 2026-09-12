# Custom tools

User-facing commands and utilities maintained in this repository. This index
is the first place to look for what a custom tool does and how to use it.

## Session secrets

| Tool | Location | Main purpose | Primary use |
| --- | --- | --- | --- |
| `session-var-add` | `shared/.config/fish/functions/session-var-add.fish` | Enter and export a secret only for the current Fish session. | `session-var-add VARIABLE_NAME` |
| `session-var-list` | `shared/.config/fish/functions/session-var-list.fish` | List the names of registered session-secret variables without values. | `session-var-list` |
| `session-var-remove` | `shared/.config/fish/functions/session-var-remove.fish` | Unset and unregister one session-secret variable. | `session-var-remove VARIABLE_NAME` |
| `session-var-clear` | `shared/.config/fish/functions/session-var-clear.fish` | Unset all registered session-secret variables and remove their registry. | `session-var-clear` |

See `~/dotfiles-skills/context/session-secrets.md` for the agent-facing safety
contract. Secret values must never be added to this index.

## Interactive tools

| Tool | Location | Main purpose | Primary use |
| --- | --- | --- | --- |
| `port-kill` | `tools/port-kill/` | Inspect listening TCP services and, after confirmation, stop a local process by port. | `cd tools/port-kill && cargo run --release` or install with `cargo install --path .` |

## Executable helpers

| Tool | Location | Main purpose | Primary use |
| --- | --- | --- | --- |
| `dokploy-account` | `shared/.local/bin/dokploy-account` | Manage multiple Dokploy accounts and run the CLI with one selected account. | `dokploy-account --help` |
| `engram-cloud-link` | `shared/.local/bin/engram-cloud-link` | Enroll the current repository with Engram Cloud and synchronize it. | `engram-cloud-link` |
| `forge-keys` | `shared/.local/bin/forge-keys` | Configure, import, load, and inspect managed Forge SSH keys. | `forge-keys --help` |
| `generate-engram-projects-yml` | `shared/.local/bin/generate-engram-projects-yml` | Scan repositories and generate an editable Engram project map. | `generate-engram-projects-yml [ROOT] [--output DIR]` |
| `restore-forge-ssh-agent` | `shared/.local/bin/restore-forge-ssh-agent` | Restore the stable SSH-agent link after a forwarded Forge socket changes. | `restore-forge-ssh-agent` |
| `setup-engram-projects` | `shared/.local/bin/setup-engram-projects` | Apply a generated Engram project map to the configured Engram server. | `setup-engram-projects [CONFIG.yml]` |
| `test-network` | `shared/.local/bin/test-network` | Check basic IP connectivity and DNS resolution. | `test-network` |
| `update-coding-agents` | `shared/.local/bin/update-coding-agents` | Check, update, and schedule updates for the configured coding-agent CLIs. | `update-coding-agents --help` |
| `watch-zone-identifiers` | `shared/.local/bin/watch-zone-identifiers` | Watch a directory and remove unwanted Windows `Zone.Identifier` metadata. | `watch-zone-identifiers [DIRECTORY]` |

## Fish functions

| Tool | Location | Main purpose | Primary use |
| --- | --- | --- | --- |
| `alacritty-sync` | `shared/.config/fish/functions/alacritty-sync.fish` | Sync the shared Alacritty configuration to Windows AppData. | `alacritty-sync` |
| `git-exclude` | `shared/.config/fish/functions/git-exclude.fish` | Add a pattern to the current repository's local `.git/info/exclude`. | `git-exclude PATTERN` |
| `listening` | `shared/.config/fish/functions/listening.fish` | Inspect listening ports, optionally filtered by a pattern. | `listening [PATTERN]` |
| `myip` | `shared/.config/fish/functions/myip.fish` | Show the public IP address. | `myip` |
| `sftp-here` | `shared/.config/fish/functions/sftp-here.fish` | Open the current SSH directory through a local SFTP client. | `sftp-here [REMOTE_PATH]` |
| `zr` | `shared/.config/fish/functions/zr.fish` | Open a remote folder on `r0n1n` through Zed SSH remote. | `zr [PATH]` |

## Maintenance rule

When a custom tool is added or its primary behavior changes, update this
document in the same commit with its purpose and primary usage. If the tool
has detailed documentation elsewhere, link it from the relevant entry rather
than duplicating the full guide here.
