#!/bin/zsh

# Homebrew (installed at /home/linuxbrew on Linux/WSL2)
[[ -x /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Use 1Password auth sock
export SSH_AUTH_SOCK=~/.1password/agent.sock
