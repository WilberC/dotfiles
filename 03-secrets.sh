#!/usr/bin/env bash
# Clone dotfiles-secrets (env files, PEM keys, etc).
# Can be run standalone: bash 03-secrets.sh
set -euo pipefail
source "$(dirname "$0")/_common.sh"

SECRETS_REPO="git@github.com:WilberC/dotfiles-secrets.git"
SECRETS_DIR="$DOTFILES_DIR/dotfiles-secrets"

info "Setting up dotfiles-secrets..."
if [[ ! -d "$SECRETS_DIR" ]]; then
  git clone "$SECRETS_REPO" "$SECRETS_DIR"
  success "Cloned dotfiles-secrets"
else
  success "dotfiles-secrets already present"
fi
