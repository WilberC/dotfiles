# Open SSH Directories with SFTP

`sftp-here` turns the current directory of a remote Fish shell into an SFTP
URL for the computer running the terminal. It copies the URL to the local
clipboard and prints an OSC 8 hyperlink, making it quick to open the same
directory in a graphical file-transfer client.

The short alias is `sfh`.

## How it works

The remote host cannot launch applications on the SSH client directly.
Instead, `sftp-here` uses two terminal escape sequences:

- OSC 52 copies the generated `sftp://` URL to the client's clipboard.
- OSC 8 renders the `Open ... with SFTP` label as a hyperlink.

Fish's clipboard helper also handles the common tmux case by writing the OSC
52 sequence to the underlying client terminal. No FTP server or additional
service is required because SFTP uses the existing SSH connection service.

## Client setup

### Windows

Install WinSCP:

```powershell
winget install --exact --id WinSCP.WinSCP
```

The installer normally registers WinSCP for `sftp://` URLs. If clicking the
link does not open it, select **Options → Preferences → Integration → Register
to handle URL addresses → Make WinSCP default handler** and associate SFTP
with WinSCP in Windows Settings.

Windows Terminal and Ghostty support the terminal sequences used by the
command. If URL activation is unavailable, run `sfh`, press `Win+R`, paste the
copied URL, and press Enter.

### macOS

Install Cyberduck:

```bash
brew install --cask cyberduck
```

In Cyberduck, open **Settings → SFTP** and make Cyberduck the default handler
for SFTP URLs. Ghostty and iTerm2 support the terminal sequences used by the
command.

If URL activation is unavailable, open the URL copied by `sfh` from a local
terminal:

```bash
open "$(pbpaste)"
```

## Usage

From a Fish shell on the SSH server:

```fish
sfh
```

This targets the current directory. An absolute or relative directory can be
provided explicitly:

```fish
sfh /var/log
sftp-here ../another-project
```

Then either click **Open ... with SFTP** or paste the URL already placed in
the local clipboard. Paths with spaces and non-ASCII characters are safely
URL-encoded.

## Connection overrides

By default, the command obtains the server address and port from
`SSH_CONNECTION` and uses the remote `$USER`. This works for direct SSH
connections. NAT, a jump host, port forwarding, or a different SFTP account
may require overrides:

```fish
set -Ux SFTP_HOST forge.example.com
set -Ux SFTP_PORT 2222
set -Ux SFTP_USER wilber
```

Only set the values that differ. Remove a universal override with:

```fish
set -eU SFTP_HOST
set -eU SFTP_PORT
set -eU SFTP_USER
```

## Troubleshooting

- **The URL contains a private or unreachable IP:** set `SFTP_HOST` to the
  hostname or address used by the client computer.
- **The link is visible but not clickable:** configure the local SFTP URL
  handler, or paste the URL that `sfh` copied automatically.
- **The clipboard does not change:** confirm that the terminal permits OSC 52
  clipboard writes. The command still provides an OSC 8 link.
- **Authentication is requested:** use the same SSH key, agent, or password
  accepted by the server. The URL deliberately does not contain credentials.
- **The command reports that `SFTP_HOST` is required:** it is running outside
  an SSH session; set `SFTP_HOST` explicitly if this is intentional.

## Dotfiles location

The implementation and alias are stowed from:

```text
shared/.config/fish/functions/sftp-here.fish
shared/.config/fish/conf.d/98-aliases.fish
```

After installing or updating these dotfiles, restow the shared package when
needed:

```bash
bash ~/dotfiles/scripts/stow-shared.sh
```
