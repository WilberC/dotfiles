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

if ! command -v stow >/dev/null 2>&1; then
  error "stow not found. Install stow first, or run ./install.sh once."
  exit 1
fi

cd "$DOTFILES_DIR"

info "Stowing shared dotfiles only..."

set +e
output=$(stow --no-folding -n shared 2>&1)
status=$?
set -e

conflicts=$(printf '%s\n' "$output" | sed -nE \
  -e 's/^[[:space:]]*\* existing target is not owned by stow: //p' \
  -e 's/^[[:space:]]*\* existing target is neither a link nor a directory: //p' \
  -e 's/^.*existing target is not owned by stow: //p')

if [[ -n "$conflicts" ]]; then
  while IFS= read -r file; do
    warn "Removing conflicting path: ~/$file"
    rm -rf ~/"$file"
  done <<< "$conflicts"
elif (( status != 0 )); then
  printf '%s\n' "$output" >&2
  exit "$status"
fi

stow --no-folding shared
success "shared"
