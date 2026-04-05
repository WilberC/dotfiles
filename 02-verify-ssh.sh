#!/usr/bin/env bash
# Verify git identity and GitHub SSH access.
# Can be run standalone: bash 02-verify-ssh.sh
set -euo pipefail
source "$(dirname "$0")/_common.sh"

info "Verifying personal setup..."

echo ""
echo -e "  ${BOLD}Git identity${RESET}"
GIT_NAME="$(git config --includes --global user.name || true)"
GIT_EMAIL="$(git config --includes --global user.email || true)"
[[ -n "$GIT_NAME" ]]  && success "name:  $GIT_NAME"  || warn "user.name not set"
[[ -n "$GIT_EMAIL" ]] && success "email: $GIT_EMAIL" || warn "user.email not set"

echo ""
echo -e "  ${BOLD}Git remotes${RESET}"
DOTFILES_REMOTE="$(git -C "$DOTFILES_DIR" remote get-url origin 2>/dev/null || true)"
if echo "$DOTFILES_REMOTE" | grep -q "^https://github.com/"; then
  SSH_REMOTE="${DOTFILES_REMOTE/https:\/\/github.com\//git@github.com:}"
  git -C "$DOTFILES_DIR" remote set-url origin "$SSH_REMOTE"
  success "Switched dotfiles remote: HTTPS → SSH ($SSH_REMOTE)"
elif [[ -n "$DOTFILES_REMOTE" ]]; then
  success "dotfiles remote: $DOTFILES_REMOTE"
else
  warn "dotfiles remote not set"
fi

echo ""
echo -e "  ${BOLD}SSH — GitHub (critical)${RESET}"
SSH_CMD="ssh"
[[ "$PLATFORM" == "wsl2" ]] && SSH_CMD="ssh.exe"
SSH_RESULT="$($SSH_CMD -T -o StrictHostKeyChecking=accept-new git@github.com 2>&1 || true)"
if echo "$SSH_RESULT" | grep -q "successfully authenticated"; then
  success "GitHub SSH OK"
else
  error "GitHub SSH FAILED"
  warn "Open 1Password and make sure the SSH agent is enabled, then re-run."
  abort "Cannot continue — GitHub SSH is required to clone dotfiles-work."
fi
