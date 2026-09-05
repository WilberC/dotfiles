# Herdr

Herdr's durable user configuration is managed by the `shared` GNU Stow
package at `shared/.config/herdr/config.toml`.

Runtime files such as `plugins.json`, sessions, logs, sockets, downloaded
plugin checkouts, and plugin state are intentionally not versioned.

## Plugins

### Agent Usage

Shows context consumption, provider rate-limit windows, remaining allowance,
and reset times for agents running in Herdr.

Install and initialize it with:

```bash
herdr plugin install senna-lang/herdr-agent-usage
herdr plugin action invoke usagebar.setup
herdr server reload-config
```

The setup action prints configuration suggestions but does not rewrite the
main Herdr configuration. The required sidebar rows and keybindings are
already present in the dotfiles-managed `config.toml`.

Shortcuts (when using `herdr --remote`, connect with
`--remote-keybindings server`):

- `Ctrl+Shift+U`: open Agent Usage in a `70%` × `60%` floating popup.
- `Ctrl+Shift+M`: refresh the sidebar meters.

The plugin-specific configuration is kept at the path printed by:

```bash
herdr plugin config-dir usagebar
```

It only needs to be managed separately when customizing notification
thresholds or configuring multiple provider accounts.

## Docker group and persistent sessions

Linux supplementary groups are attached to each process when it starts. A
user can therefore appear in the `docker` group through SSH while a long-lived
Herdr server and its panes still have the older group list.

### Diagnose the mismatch

Run these commands in the working shell and in the Herdr pane, then compare
the output:

```bash
whoami
id
groups
ls -l /var/run/docker.sock
```

The Docker socket should normally look like `root docker` with read/write
permissions for the group. To inspect the groups attached to the current
process directly, run:

```bash
grep '^Groups:' /proc/$$/status
```

If SSH contains `docker` but Herdr does not, the problem is the age of the
process tree rather than the account's group membership.

### Refresh one shell

For a shell that was started before a group was added, either log out and open
a new session or start a shell with the Docker group:

```bash
newgrp docker
```

When the new shell opens, run `docker ps` there to verify access. Exit that
shell with `exit` when finished.

`newgrp` only affects that shell and its children. It does not update a
Herdr server that is already running.

### Refresh the Herdr server

Run this from a fresh SSH session that already has the required groups:

```bash
herdr server stop
setsid nohup herdr server \
  >"$HOME/.config/herdr/herdr-server-manual.log" 2>&1 \
  </dev/null &
```

The stop/start cycle can interrupt existing Herdr clients and panes. Open a
new pane after the restart so that it inherits the server's refreshed groups.
Verify the server and the new pane with:

```bash
herdr status server
id
docker ps
```

### Optional dotfiles helper

The following helper can be kept in the dotfiles for a manual group refresh;
it is intentionally not enabled automatically because it replaces the
current shell with a new login shell and may reset session-specific state.

For Fish, save this as
`shared/.config/fish/functions/refresh-groups.fish`:

```fish
function refresh-groups
    exec su -l $USER
end
```

For Bash, add the equivalent function to `.bashrc`:

```bash
refresh-groups() {
    exec su -l "$USER"
}
```

After changing account membership with `usermod -aG`, run `refresh-groups` in
the current shell. Restart persistent processes such as Herdr separately;
shell dotfiles cannot change the groups of a process that is already running.
