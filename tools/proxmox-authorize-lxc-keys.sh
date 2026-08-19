#!/usr/bin/env bash
# Run on a Proxmox VE host. Authorizes the shared Homelab SSH key on LXC
# containers via pct exec — bypasses SSH entirely, so it works even where
# PermitRootLogin blocks SSH password auth (the default on most LXC
# templates), which is why ssh-copy-homelab-keys.sh alone isn't enough
# for those. Idempotent — safe to re-run, including on newly created
# containers.
set -uo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

info()    { echo -e "${CYAN}${BOLD}::${RESET} $*"; }
success() { echo -e "${GREEN}${BOLD}✓${RESET} $*"; }
warn()    { echo -e "${YELLOW}${BOLD}!${RESET} $*"; }

# Public half of the "Local Lab SSH" key in 1Password. Update this if that
# key is ever rotated — see dotfiles/shared/.config/ssh/pubs/homelab.pub
PUBKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKLkuaU89yUzG8PBILIl4PlNcfYcvevSyVq38HlIgYEa Local Lab SSH"

usage() {
  cat <<EOF
Usage: $(basename "$0") [--all | id...]

Authorizes the shared Homelab SSH key on running LXC containers via
pct exec. Idempotent — safe to re-run any time, including after creating
new containers.

With no arguments, prompts to pick containers via fzf (Tab=mark,
Ctrl-A=all, Enter=run), or a numbered menu if fzf isn't installed. Use
--all to run on every running container without picking, or pass IDs
directly, e.g.: $(basename "$0") 110 111
EOF
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && { usage; exit 0; }

if ! command -v pct &>/dev/null; then
  echo "pct not found — run this on a Proxmox VE host." >&2
  exit 1
fi

declare -A names
while read -r id status name; do
  [[ "$status" == "running" ]] && names["$id"]="$name"
done < <(pct list 2>/dev/null | awk 'NR>1{print $1, $2, $NF}')

all_ids=("${!names[@]}")

if [[ ${#all_ids[@]} -eq 0 ]]; then
  echo "No running LXC containers found."
  exit 0
fi

if [[ "${1:-}" == "--all" ]]; then
  ids=("${all_ids[@]}")
elif [[ $# -gt 0 ]]; then
  ids=("$@")
  for id in "${ids[@]}"; do
    if [[ -z "${names[$id]:-}" ]]; then
      echo "Unknown or not running LXC ID: $id (running: ${all_ids[*]})" >&2
      exit 1
    fi
  done
else
  options=()
  for id in "${all_ids[@]}"; do
    options+=("$id  ${names[$id]}")
  done

  if command -v fzf &>/dev/null; then
    mapfile -t picked < <(printf '%s\n' "${options[@]}" | fzf -m --bind 'ctrl-a:select-all' --prompt="Select LXC(s) (Tab=mark, Ctrl-A=all) > ")
  else
    warn "fzf not found — falling back to a numbered menu (space-separated numbers for multiple)"
    i=1
    for o in "${options[@]}"; do
      echo "  $i) $o"
      ((i++))
    done
    read -rp "Select: " -a nums
    picked=()
    for n in "${nums[@]}"; do
      picked+=("${options[$((n - 1))]}")
    done
  fi

  ids=()
  for p in "${picked[@]}"; do
    ids+=("${p%% *}")
  done
fi

if [[ ${#ids[@]} -eq 0 ]]; then
  warn "No container selected — nothing to do"
  exit 0
fi

for id in "${ids[@]}"; do
  name="${names[$id]:-$id}"
  result="$(pct exec "$id" -- bash -c "
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    touch /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    line='$PUBKEY'
    if grep -qxF \"\$line\" /root/.ssh/authorized_keys; then
      echo ALREADY_PRESENT
    else
      echo \"\$line\" >> /root/.ssh/authorized_keys
      echo ADDED
    fi
  " 2>/dev/null)"

  case "$result" in
    ADDED) success "$id ($name): key added" ;;
    ALREADY_PRESENT) info "$id ($name): key already present, skipped" ;;
    *) echo "$id ($name): unexpected result: $result" >&2 ;;
  esac
done
