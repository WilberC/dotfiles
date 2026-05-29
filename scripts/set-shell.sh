#!/usr/bin/env bash
set -euo pipefail

BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RESET='\033[0m'

info()    { echo -e "${CYAN}${BOLD}::${RESET} $*"; }
success() { echo -e "${GREEN}${BOLD}✓${RESET} $*"; }
error()   { echo -e "${RED}${BOLD}✗${RESET} $*"; }

SHELL_NAME="${1:-}"

if [[ -z "$SHELL_NAME" ]]; then
  error "Usage: $0 <fish|zsh|bash>"
  exit 1
fi

SHELL_BIN=$(which "$SHELL_NAME" 2>/dev/null || true)

if [[ -z "$SHELL_BIN" ]]; then
  error "$SHELL_NAME not found in PATH — install it first"
  exit 1
fi

if ! grep -qF "$SHELL_BIN" /etc/shells; then
  info "Adding $SHELL_BIN to /etc/shells..."
  echo "$SHELL_BIN" | sudo tee -a /etc/shells > /dev/null
fi

if [[ "$SHELL" == "$SHELL_BIN" ]]; then
  success "Already using $SHELL_NAME ($SHELL_BIN)"
  exit 0
fi

info "Changing default shell to $SHELL_NAME ($SHELL_BIN)..."
chsh -s "$SHELL_BIN"
success "Default shell set to $SHELL_NAME — restart terminal to apply"
