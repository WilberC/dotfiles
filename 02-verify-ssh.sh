#!/usr/bin/env bash
# Verify git identity and GitHub SSH access.
# Can be run standalone: bash 02-verify-ssh.sh
set -euo pipefail
source "$(dirname "$0")/_common.sh"

info "Verifying personal setup..."

echo ""
echo -e "  ${BOLD}Git identity${RESET}"
GIT_NAME="$(git config --global user.name || true)"
GIT_EMAIL="$(git config --global user.email || true)"
[[ -n "$GIT_NAME" ]]  && success "name:  $GIT_NAME"  || warn "user.name not set"
[[ -n "$GIT_EMAIL" ]] && success "email: $GIT_EMAIL" || warn "user.email not set"

echo ""
echo -e "  ${BOLD}SSH — GitHub (critical)${RESET}"
SSH_RESULT="$(ssh -T git@github.com 2>&1 || true)"
if echo "$SSH_RESULT" | grep -q "successfully authenticated"; then
  success "GitHub SSH OK"
else
  error "GitHub SSH FAILED"
  warn "Open 1Password and make sure the SSH agent is enabled, then re-run."
  abort "Cannot continue — GitHub SSH is required to clone dotfiles-work."
fi
