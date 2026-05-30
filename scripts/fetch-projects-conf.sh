#!/usr/bin/env bash
set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
RESET='\033[0m'

info()    { echo -e "${CYAN}${BOLD}::${RESET} $*"; }
success() { echo -e "${GREEN}${BOLD}✓${RESET} $*"; }
warn()    { echo -e "${YELLOW}${BOLD}!${RESET} $*"; }
error()   { echo -e "${RED}${BOLD}✗${RESET} $*"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONF="$DOTFILES_DIR/projects.conf"

OP_ITEM="${OP_PROJECTS_CONF_ITEM:-dotfiles/projects.conf}"
OP_VAULT="${OP_PROJECTS_CONF_VAULT:-}"

if ! command -v op &>/dev/null; then
  error "1Password CLI not found — install from https://developer.1password.com/docs/cli/"
  exit 1
fi

if ! op whoami &>/dev/null 2>&1; then
  info "Not signed in to 1Password — signing in..."
  op signin || { error "1Password sign-in failed"; exit 1; }
fi

vault_flag=()
[[ -n "$OP_VAULT" ]] && vault_flag=(--vault "$OP_VAULT")

info "Fetching projects.conf from 1Password (item: $OP_ITEM)..."
if op item get "$OP_ITEM" "${vault_flag[@]}" --fields notesPlain 2>/dev/null \
    | sed '1s/^"//; $d' > "$CONF"; then
  success "projects.conf saved to $CONF"
else
  error "Item '$OP_ITEM' not found in 1Password"
  warn "See docs/projects-conf-1password.md for setup instructions"
  exit 1
fi
