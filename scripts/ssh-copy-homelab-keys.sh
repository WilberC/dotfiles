#!/usr/bin/env bash
set -euo pipefail

# Hosts that can't (or shouldn't) go through this script — excluded from
# the picker/default run/--all, but can still be targeted explicitly by
# name. hermes: already authorized manually. The rest are LXC containers,
# whose templates default to PermitRootLogin prohibit-password (blocks
# SSH password auth entirely) — those go through
# tools/proxmox-authorize-lxc-keys.sh (pct exec) instead, which never
# touches SSH.
SKIP_HOSTS=(hermes adguard tailscale cloudflared traefik authelia nas)

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

info()    { echo -e "${CYAN}${BOLD}::${RESET} $*"; }
success() { echo -e "${GREEN}${BOLD}✓${RESET} $*"; }
warn()    { echo -e "${YELLOW}${BOLD}!${RESET} $*"; }

usage() {
  cat <<EOF
Usage: $(basename "$0") [--all | host...]

Copies each homelab host's configured SSH key (via IdentityFile) to that
host's ~/.ssh/authorized_keys. Idempotent — safe to re-run, already-present
keys are skipped. Password auth is left untouched — this only adds a new
login method.

With no arguments, you'll be prompted to pick one or more hosts via fzf —
Tab to mark each one, Ctrl-A to mark all shown, Enter to run on everything
marked at once — or a numbered menu (space-separated numbers) if fzf isn't
installed. Pass host names directly to skip the picker, e.g.:
$(basename "$0") forge dokploy
Or use --all to run on every selectable host without picking at all.

Hosts already authorized manually (see SKIP_HOSTS in this script) are
excluded from the picker, "no arguments" runs, and --all, but can still be
targeted explicitly by name.
EOF
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && { usage; exit 0; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONF="$DOTFILES_DIR/shared/.config/ssh/configs/homelab.conf"

[[ -f "$CONF" ]] || { echo "Not found: $CONF" >&2; exit 1; }

mapfile -t all_hosts < <(grep -E '^Host ' "$CONF" | awk '{print $2}' | grep -v '^\*$')

is_skipped() {
  local h="$1" s
  for s in "${SKIP_HOSTS[@]}"; do
    [[ "$h" == "$s" ]] && return 0
  done
  return 1
}

is_known_host() {
  local h="$1" s
  for s in "${all_hosts[@]}"; do
    [[ "$h" == "$s" ]] && return 0
  done
  return 1
}

selectable=()
for host in "${all_hosts[@]}"; do
  is_skipped "$host" || selectable+=("$host")
done

if [[ "${1:-}" == "--all" ]]; then
  if [[ ${#selectable[@]} -eq 0 ]]; then
    echo "No selectable hosts in $CONF (all skipped or none defined)"
    exit 0
  fi
  hosts=("${selectable[@]}")
elif [[ $# -gt 0 ]]; then
  hosts=("$@")
  for host in "${hosts[@]}"; do
    if ! is_known_host "$host"; then
      echo "Unknown host: $host (available: ${all_hosts[*]})" >&2
      exit 1
    fi
  done
else
  if [[ ${#selectable[@]} -eq 0 ]]; then
    echo "No selectable hosts in $CONF (all skipped or none defined)"
    exit 0
  fi

  if command -v fzf &>/dev/null; then
    mapfile -t hosts < <(printf '%s\n' "${selectable[@]}" | fzf -m --bind 'ctrl-a:select-all' --prompt="Select homelab host(s) (Tab=mark, Ctrl-A=all) > ")
  else
    warn "fzf not found — falling back to a numbered menu (space-separated numbers for multiple)"
    i=1
    for h in "${selectable[@]}"; do
      echo "  $i) $h"
      ((i++))
    done
    read -rp "Select host(s): " -a nums
    hosts=()
    for n in "${nums[@]}"; do
      hosts+=("${selectable[$((n - 1))]}")
    done
  fi
fi

if [[ ${#hosts[@]} -eq 0 ]]; then
  warn "No host selected — nothing to do"
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
  # Not ssh-copy-id: its default "already installed?" check needs the
  # private key, which deliberately never exists on disk here (the key
  # lives only in 1Password), and its -f/force mode skips that check but
  # then always appends — duplicating the line on every re-run. This does
  # the same append ssh-copy-id would, but checks for an exact existing
  # match first, in the same connection, so re-running is a clean no-op.
  result="$(ssh "$host" '
    set -e
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    touch ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
    line="$(cat)"
    if grep -qxF "$line" ~/.ssh/authorized_keys; then
      echo ALREADY_PRESENT
    else
      echo "$line" >> ~/.ssh/authorized_keys
      echo ADDED
    fi
  ' < "$key")"

  case "$result" in
    ADDED) success "$host: key added" ;;
    ALREADY_PRESENT) info "$host: key already present, skipped" ;;
    *) echo "$host: unexpected result: $result" >&2 ;;
  esac
  echo
done

success "Done. Password auth is untouched — key is just a new option."
