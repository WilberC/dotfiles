# port-kill

A small interactive Rust CLI for stopping a listening TCP service by port on native Linux, WSL2 Ubuntu, or macOS.

## Requirements

`port-kill` supports Unix processes on these platforms:

- Native Linux
- Ubuntu running in WSL2
- macOS

Install Rust with [rustup](https://rustup.rs/), then ensure `lsof` is available:

```bash
# Ubuntu, including Ubuntu on WSL2
sudo apt update && sudo apt install lsof
```

macOS normally includes `lsof` at `/usr/sbin/lsof`. If it has been removed or is unavailable, install it with your system package manager. If Rust cannot build because developer tools are missing, run `xcode-select --install` first.

## Use

Run it from this directory:

```bash
cargo run --release
```

It opens one full-screen terminal view. Local services and, on WSL2, Windows-host services appear in clearly separated sections in that same view. Each section is sorted by port and shows the port, PID, user, process, and bound address. Use the arrow keys or `j`/`k` and Enter to choose a service; `q`, Esc, or Ctrl-C cancels. The tool asks for confirmation before it sends `SIGTERM` to a selected Linux or macOS PID.

`lsof` must be installed and the command must run in an interactive terminal. If `lsof` is unavailable, no listeners exist, input is not a terminal, or you cancel, the tool does not stop anything.

For a reusable binary:

```bash
cargo install --path .
port-kill
```

The tool uses `SIGTERM`, not `SIGKILL`; a process may choose to handle or ignore the signal.

To see usage without opening the interactive picker:

```bash
port-kill --help
# or
port-kill help
```

## WSL2 scope

Run `port-kill` inside the Ubuntu distribution. On WSL2, it displays both sides in two sections within the same terminal view:

- `Linux` entries are processes in that WSL distribution and can be selected and stopped with `SIGTERM`.
- `Windows` entries are listeners on the Windows host, discovered through `powershell.exe` only when WSL2 is detected. They are informational-only: selecting one never stops a Windows process.

This split matters because a port may exist in either environment, or in both. Native Linux and macOS never invoke Windows tooling and show only their local listeners.

### Windows `portproxy`

When Windows has a `netsh interface portproxy` rule, Windows commonly reports the listener as `svchost.exe` / **IP Helper**. `port-kill` labels a matching entry as `portproxy (IP Helper)` rather than offering to kill that system process. Selecting it prints the exact elevated Windows PowerShell command needed to remove that forwarding rule, for example:

```powershell
netsh interface portproxy delete v4tov4 listenport=8000 listenaddress=0.0.0.0
```

Removing a portproxy rule changes Windows networking; `port-kill` deliberately does not perform that change automatically.
