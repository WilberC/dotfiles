#!/usr/bin/env bash
set -uo pipefail

if [[ -n "${NO_COLOR:-}" || "${TERM:-}" == "dumb" ]]; then
  RESET=''
  BOLD=''
  RED=''
  GREEN=''
  YELLOW=''
  CYAN=''
else
  RESET=$'\033[0m'
  BOLD=$'\033[1m'
  RED=$'\033[31m'
  GREEN=$'\033[32m'
  YELLOW=$'\033[33m'
  CYAN=$'\033[36m'
fi

info() { printf '%b%s%b\n' "${CYAN}${BOLD}" "$*" "$RESET"; }
success() { printf '%b✓%b %s\n' "${GREEN}${BOLD}" "$RESET" "$*"; }
warn() { printf '%b!%b %s\n' "${YELLOW}${BOLD}" "$RESET" "$*" >&2; }
error() { printf '%b✗%b %s\n' "${RED}${BOLD}" "$RESET" "$*" >&2; }

DOTFILES_PARENT="${DOTFILES_PARENT:-$HOME}"
updated=0
failed=0

for repository in "$DOTFILES_PARENT/dotfiles" "$DOTFILES_PARENT"/dotfiles-*; do
  [[ -d "$repository" ]] || continue

  if ! git -C "$repository" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    warn "Skipping $repository: not a Git repository"
    continue
  fi

  info "Updating $repository"
  if git -C "$repository" pull --ff-only; then
    updated=$((updated + 1))
    success "Updated $repository"
  else
    error "Failed to update $repository"
    failed=$((failed + 1))
  fi
done

if [[ $updated -eq 1 ]]; then
  success "Updated 1 dotfiles repository"
else
  success "Updated $updated dotfiles repositories"
fi

if [[ $failed -gt 0 ]]; then
  error "$failed repository update(s) failed"
  exit 1
fi
