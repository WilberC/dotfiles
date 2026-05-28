#!/usr/bin/env bash
# Clones and installs dotfiles-work (private work overlay).
# Requires SSH to be configured and 1Password agent running.
set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
RESET='\033[0m'

info()    { echo -e "${CYAN}${BOLD}::${RESET} $*"; }
success() { echo -e "${GREEN}${BOLD}✓${RESET} $*"; }
warn()    { echo -e "${YELLOW}${BOLD}!${RESET} $*"; }
error()   { echo -e "${RED}${BOLD}✗${RESET} $*"; }

WORK_REPO="git@github.com:WilberC/dotfiles-work.git"
WORK_DIR="$HOME/dotfiles-work"

# SSH is required — fail fast with a clear message
info "Verifying SSH access to GitHub..."
SSH_RESULT="$(ssh -T git@github.com 2>&1 || true)"
if ! echo "$SSH_RESULT" | grep -qi "successfully authenticated"; then
  error "SSH not working — configure 1Password SSH agent first, then re-run:"
  echo ""
  echo -e "    ${BOLD}bash scripts/setup-work.sh${RESET}"
  echo ""
  exit 1
fi
success "SSH OK"

if [[ -d "$WORK_DIR/.git" ]]; then
  success "dotfiles-work already at $WORK_DIR"
else
  info "Cloning dotfiles-work..."
  git clone "$WORK_REPO" "$WORK_DIR"
  success "cloned to $WORK_DIR"
fi

info "Running dotfiles-work install..."
bash "$WORK_DIR/install.sh"
