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

# 1Password SSH key title (comment on the public key) -> repo-relative .pub path.
# Add an entry here whenever a new key is created for a host this repo manages.
declare -A PUB_MAP=(
  ["Github M1"]="shared/.config/ssh/pubs/github.pub"
  ["Local Lab SSH"]="shared/.config/ssh/pubs/homelab.pub"
)

if ! command -v ssh-add &>/dev/null; then
  error "ssh-add not found"
  exit 1
fi

if [[ -z "${SSH_AUTH_SOCK:-}" ]]; then
  SSH_AUTH_SOCK="$(ssh -G localhost 2>/dev/null | awk '/^identityagent /{print $2}' | sed "s|^~|$HOME|")"
  export SSH_AUTH_SOCK
fi

if [[ -z "${SSH_AUTH_SOCK:-}" || ! -S "$SSH_AUTH_SOCK" ]]; then
  error "1Password SSH agent socket not reachable (${SSH_AUTH_SOCK:-unset}) — is the app running and unlocked?"
  exit 1
fi

declare -A AGENT_KEYS=()
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  rest="${line#* }"  # drop key type
  rest="${rest#* }"  # drop base64 blob, leaving the comment
  AGENT_KEYS["$rest"]="$line"
done < <(ssh-add -L 2>/dev/null)

if [[ ${#AGENT_KEYS[@]} -eq 0 ]]; then
  error "Agent returned no keys — is 1Password's SSH agent unlocked?"
  exit 1
fi

status=0
for comment in "${!PUB_MAP[@]}"; do
  rel_path="${PUB_MAP[$comment]}"
  target="$DOTFILES_DIR/$rel_path"

  if [[ -z "${AGENT_KEYS[$comment]:-}" ]]; then
    warn "No agent key titled \"$comment\" — skipping $rel_path"
    status=1
    continue
  fi

  mkdir -p "$(dirname "$target")"
  printf '%s\n' "${AGENT_KEYS[$comment]}" > "$target"
  chmod 600 "$target"
  success "$rel_path ← \"$comment\""
done

exit "$status"
