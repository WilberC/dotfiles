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
KEY="$HOME/.config/ssh/pubs/homelab.pub"

[[ -f "$CONF" ]] || { echo "Not found: $CONF" >&2; exit 1; }
[[ -f "$KEY" ]] || { echo "Not found: $KEY" >&2; exit 1; }

mapfile -t hosts < <(grep -E '^Host ' "$CONF" | awk '{print $2}' | grep -v '^\*$')

if [[ ${#hosts[@]} -eq 0 ]]; then
  echo "No hosts found in $CONF"
  exit 0
fi

info "Copying ${KEY} to: ${hosts[*]}"
echo

for host in "${hosts[@]}"; do
  echo "── $host ──────────────────────────────"
  ssh-copy-id -i "$KEY" "$host"
  success "$host done"
  echo
done

success "All hosts processed. Password auth is untouched — key is just a new option."
