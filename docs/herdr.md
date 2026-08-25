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

Shortcuts:

- `Ctrl+Shift+U`: open the Agent Usage limits pane.
- `Ctrl+Shift+M`: refresh the sidebar meters.

The plugin-specific configuration is kept at the path printed by:

```bash
herdr plugin config-dir usagebar
```

It only needs to be managed separately when customizing notification
thresholds or configuring multiple provider accounts.
