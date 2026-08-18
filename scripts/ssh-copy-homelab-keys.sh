#!/usr/bin/env bash
set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RESET='\033[0m'

info()    { echo -e "${CYAN}${BOLD}::${RESET} $*"; }
success() { echo -e "${GREEN}${BOLD}✓${RESET} $*"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONF="$DOTFILES_DIR/shared/.config/ssh/configs/homelab.conf"

[[ -f "$CONF" ]] || { echo "Not found: $CONF" >&2; exit 1; }

# Hosts already authorized manually outside this script — skip so it
# doesn't re-prompt for their password unnecessarily.
SKIP_HOSTS=(hermes)

mapfile -t all_hosts < <(grep -E '^Host ' "$CONF" | awk '{print $2}' | grep -v '^\*$')
hosts=()
for host in "${all_hosts[@]}"; do
  skip=false
  for s in "${SKIP_HOSTS[@]}"; do
    [[ "$host" == "$s" ]] && { skip=true; break; }
  done
  "$skip" || hosts+=("$host")
done

if [[ ${#hosts[@]} -eq 0 ]]; then
  echo "No hosts found in $CONF"
  exit 0
fi

info "Copying each host's configured key to: ${hosts[*]}"
echo

for host in "${hosts[@]}"; do
  key="$(ssh -G "$host" | awk '/^identityfile /{print $2; exit}')"
  key="${key/#\~/$HOME}"

  if [[ -z "$key" || ! -f "$key" ]]; then
    echo "── $host ── skipped: no IdentityFile resolved (${key:-none}) ──"
    echo
    continue
  fi

  echo "── $host ── ${key} ──────────────────────────────"
  ssh-copy-id -i "$key" "$host"
  success "$host done"
  echo
done

success "All hosts processed. Password auth is untouched — key is just a new option."
