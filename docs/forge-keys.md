# Forge headless SSH keys

Forge keeps its private SSH keys as machine-local state so Git authentication
and commit signing remain available from Herdr, Moshi, or any SSH client. Only
the automation is versioned in dotfiles; private material never enters a Git
repository.

## Storage boundary

Private keys are stored only on Forge:

```text
~/.local/share/forge-keys/keys/
```

The directory uses mode `700` and each private key uses mode `600`. Keys are
intentionally unencrypted on this trusted, always-on host so systemd can load
them without interaction after a reboot.

## Setup

Prepare the machine-local service:

```bash
forge-keys setup
```

Import every required key with one idempotent command:

```bash
forge-keys import
```

The command discovers required keys from the installed public SSH
configuration. It skips valid local keys, signs in to 1Password only when a
key is missing, and finds the corresponding SSH Key item by its public-key
fingerprint instead of relying on its title. It downloads a private key only
after that match, requests it from 1Password in OpenSSH format, and verifies
the fingerprint again before installation.

The first successful import enables the autoload service. Running the command
again performs no downloads when every required key is already valid.

## Operation

Inspect the persistent agent:

```bash
forge-keys status
```

Reload every managed key:

```bash
forge-keys load
```

Disable automatic loading without deleting stored keys:

```bash
forge-keys disable
```

The generated user service loads keys into:

```text
/run/user/1000/openssh_agent
```

The Fish configuration selects this socket only on a host whose short hostname
is exactly `forge` and only after the first key has been imported. Other hosts
continue using their normal 1Password or forwarded-agent configuration.
