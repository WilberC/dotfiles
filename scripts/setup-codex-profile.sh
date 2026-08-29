#!/usr/bin/env bash
set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RESET='\033[0m'

info()    { echo -e "${CYAN}${BOLD}::${RESET} $*"; }
success() { echo -e "${GREEN}${BOLD}✓${RESET} $*"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$DOTFILES_DIR/templates/codex/dotfiles.config.toml"
PROFILE_DIR="${CODEX_HOME:-$HOME/.codex}"
PROFILE="$PROFILE_DIR/dotfiles.config.toml"

mkdir -p "$PROFILE_DIR"

if [[ -L "$PROFILE" ]]; then
  info "Migrating the Codex profile from a symlink to a local file..."
  temporary_profile=$(mktemp "$PROFILE_DIR/dotfiles.config.toml.migrate.XXXXXX")

  if [[ -e "$PROFILE" ]]; then
    cp -L "$PROFILE" "$temporary_profile"
  else
    cp "$TEMPLATE" "$temporary_profile"
  fi

  chmod 600 "$temporary_profile"
  rm "$PROFILE"
  mv "$temporary_profile" "$PROFILE"
  success "Codex profile migrated: $PROFILE"
elif [[ -e "$PROFILE" ]]; then
  success "Codex profile already exists: $PROFILE"
else
  info "Creating the local Codex profile from its template..."
  install -m 600 "$TEMPLATE" "$PROFILE"
  success "Codex profile created: $PROFILE"
fi
