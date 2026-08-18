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

usage() {
  cat <<EOF
Usage: $(basename "$0") [push|pull] [group...]

Syncs private SSH config groups (shared/.config/ssh/configs/<group>.conf)
with 1Password, since this repo is public. Any <group>.conf.example file
in that directory is a discoverable group.

With no action, you'll be prompted to pick push or pull.
With no group, you'll be prompted to pick one or more via fzf (or a
numbered menu if fzf isn't installed).

Env overrides:
  OP_SSH_CONFIG_VAULT   1Password vault to use (default: your default vault)
EOF
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && { usage; exit 0; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIGS_DIR="$DOTFILES_DIR/shared/.config/ssh/configs"
OP_VAULT="${OP_SSH_CONFIG_VAULT:-}"

vault_flag=()
[[ -n "$OP_VAULT" ]] && vault_flag=(--vault "$OP_VAULT")

discover_groups() {
  local f base
  for f in "$CONFIGS_DIR"/*.conf.example; do
    [[ -e "$f" ]] || continue
    base="$(basename "$f")"
    echo "${base%.conf.example}"
  done
}

mapfile -t AVAILABLE_GROUPS < <(discover_groups)

if [[ ${#AVAILABLE_GROUPS[@]} -eq 0 ]]; then
  error "No groups found — expected shared/.config/ssh/configs/<group>.conf.example"
  exit 1
fi

# --- action ---
ACTION="${1:-}"
if [[ "$ACTION" == "push" || "$ACTION" == "pull" ]]; then
  shift
elif [[ -z "$ACTION" ]]; then
  info "Pick an action:"
  select choice in push pull; do
    [[ -n "$choice" ]] && ACTION="$choice" && break
  done
else
  error "Unknown action: $ACTION (expected push or pull)"
  usage
  exit 1
fi

# --- groups ---
SEL_GROUPS=("$@")
if [[ ${#SEL_GROUPS[@]} -eq 0 ]]; then
  if command -v fzf &>/dev/null; then
    mapfile -t SEL_GROUPS < <(printf '%s\n' "${AVAILABLE_GROUPS[@]}" | fzf -m --prompt="Select ssh-config group(s) > ")
  else
    warn "fzf not found — falling back to a numbered menu (space-separated numbers for multiple)"
    select_menu=()
    i=1
    for g in "${AVAILABLE_GROUPS[@]}"; do
      echo "  $i) $g"
      select_menu+=("$g")
      ((i++))
    done
    read -rp "Select group(s): " -a nums
    SEL_GROUPS=()
    for n in "${nums[@]}"; do
      SEL_GROUPS+=("${select_menu[$((n - 1))]}")
    done
  fi
fi

if [[ ${#SEL_GROUPS[@]} -eq 0 ]]; then
  warn "No group selected — nothing to do"
  exit 0
fi

for group in "${SEL_GROUPS[@]}"; do
  if [[ ! " ${AVAILABLE_GROUPS[*]} " =~ " $group " ]]; then
    error "Unknown group: $group (available: ${AVAILABLE_GROUPS[*]})"
    exit 1
  fi
done

if ! command -v op &>/dev/null; then
  error "1Password CLI not found — install from https://developer.1password.com/docs/cli/"
  exit 1
fi

if ! op whoami &>/dev/null 2>&1; then
  info "Not signed in to 1Password — signing in..."
  eval "$(op signin)" || { error "1Password sign-in failed"; exit 1; }
fi

RESTOW_NEEDED=false

for group in "${SEL_GROUPS[@]}"; do
  CONF="$CONFIGS_DIR/$group.conf"
  OP_ITEM="dotfiles/${group}-ssh.conf"

  if [[ "$ACTION" == "push" ]]; then
    if [[ ! -f "$CONF" ]]; then
      error "$CONF not found — nothing to push"
      warn "Copy the template first: cp $CONFIGS_DIR/$group.conf.example $CONF"
      exit 1
    fi
    if op item get "$OP_ITEM" ${vault_flag[@]+"${vault_flag[@]}"} &>/dev/null; then
      info "Updating existing 1Password item ($OP_ITEM)..."
      op item edit "$OP_ITEM" ${vault_flag[@]+"${vault_flag[@]}"} "notesPlain=$(cat "$CONF")" >/dev/null
    else
      info "Creating new 1Password item ($OP_ITEM)..."
      op item create --category "Secure Note" --title "$OP_ITEM" ${vault_flag[@]+"${vault_flag[@]}"} "notesPlain=$(cat "$CONF")" >/dev/null
    fi
    success "Pushed $group ($CONF → $OP_ITEM)"
  else
    info "Fetching $group from 1Password (item: $OP_ITEM)..."
    if op item get "$OP_ITEM" ${vault_flag[@]+"${vault_flag[@]}"} --fields notesPlain 2>/dev/null \
        | sed '1s/^"//; $d' > "$CONF"; then
      success "Pulled $group ($OP_ITEM → $CONF)"
      [[ ! -L "$HOME/.config/ssh/configs/$group.conf" ]] && RESTOW_NEEDED=true
    else
      error "Item '$OP_ITEM' not found in 1Password"
      warn "First time on this machine? Create it with: $(basename "$0") push $group"
      exit 1
    fi
  fi
done

if [[ "$RESTOW_NEEDED" == true ]]; then
  info "Linking new file(s) into ~/.config/ssh/configs via stow..."
  bash "$DOTFILES_DIR/scripts/stow-shared.sh"
fi
