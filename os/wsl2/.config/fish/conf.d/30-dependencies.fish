# OS specific dependencies (WSL2)

# ssh/ssh-add use native WSL OpenSSH (not ssh.exe), reading ~/.ssh/config
# directly. Key material comes from 1Password via the WSL agent socket
# bridged by the 1password-ssh-agent-relay systemd service (see
# os/wsl2/.local/bin/1password-ssh-agent-relay).
