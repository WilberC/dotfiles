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

if [[ ! -f "$CONF" ]]; then
  warn "projects.conf not found — attempting to fetch from 1Password..."
  if ! bash "$DOTFILES_DIR/scripts/fetch-projects-conf.sh"; then
    error "projects.conf is required to continue."
    info  "Fetch it manually and re-run:"
    echo  ""
    echo  "    bash scripts/fetch-projects-conf.sh"
    echo  "    bash scripts/setup-dirs.sh"
    echo  ""
    exit 1
  fi
fi

info "Creating project directories from projects.conf..."

while IFS= read -r line; do
  [[ -z "$line" || "$line" == \#* ]] && continue
  dir="${HOME}/${line}"
  if [[ -d "$dir" ]]; then
    success "exists: $dir"
  else
    mkdir -p "$dir"
    success "created: $dir"
  fi
done < "$CONF"
