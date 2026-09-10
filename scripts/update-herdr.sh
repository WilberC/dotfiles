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

REMOTE_HOST="${HERDR_REMOTE_HOST:-forge}"
HANDOFF=1
UPDATE_LOCAL=1
UPDATE_REMOTE=1

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Updates Herdr in the current environment and then updates Forge only when its
version differs. It tries a live handoff so existing Herdr sessions and panes
can keep running. It never stops a server automatically.

Options:
  --no-handoff     Install the update without attempting live handoff.
  --local-only     Update only the local WSL client/server.
  --remote-only    Update only Forge.
  -h, --help       Show this help.

Environment:
  HERDR_REMOTE_HOST  SSH target to update (default: forge).
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-handoff) HANDOFF=0 ;;
    --local-only) UPDATE_REMOTE=0 ;;
    --remote-only) UPDATE_LOCAL=0 ;;
    -h|--help) usage; exit 0 ;;
    *) error "Unknown option: $1"; usage >&2; exit 1 ;;
  esac
  shift
done

if ! command -v mise >/dev/null 2>&1; then
  error "mise was not found; Herdr updates must run through mise."
  exit 1
fi

herdr_version() {
  local output
  output="$1"
  printf '%s\n' "$output" | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1
}

HERDR_UPDATE_ARGS=(update)
if [[ "$HANDOFF" -eq 1 ]]; then
  HERDR_UPDATE_ARGS+=(--handoff)
fi

if [[ "$UPDATE_LOCAL" -eq 1 ]]; then
  local_version_before="$(mise exec -- herdr --version)"
  info "Current local Herdr: ${local_version_before}"
  info "Updating local Herdr..."
  mise exec -- herdr "${HERDR_UPDATE_ARGS[@]}"
  local_version_output="$(mise exec -- herdr --version)"
  local_version="$(herdr_version "$local_version_output")"
  [[ -n "$local_version" ]] || { error "Could not parse local Herdr version: $local_version_output"; exit 1; }
  success "Local Herdr: ${local_version_output}"
fi

if [[ "$UPDATE_REMOTE" -eq 1 ]]; then
  info "Checking SSH access to ${REMOTE_HOST}..."
  ssh -o ClearAllForwardings=yes -o ConnectTimeout=8 "$REMOTE_HOST" \
    'command -v mise >/dev/null'

  remote_version_output="$(ssh -o ClearAllForwardings=yes "$REMOTE_HOST" \
    'mise exec -- herdr --version'
  )"
  remote_version="$(herdr_version "$remote_version_output")"
  [[ -n "$remote_version" ]] || { error "Could not parse Forge Herdr version: $remote_version_output"; exit 1; }
  info "Current Forge Herdr: ${remote_version_output}"

  if [[ "$UPDATE_LOCAL" -eq 1 && "$local_version" == "$remote_version" ]]; then
    success "Forge already matches local Herdr ${local_version}; skipping remote update"
  else
    info "Updating Herdr on ${REMOTE_HOST}..."
    if ssh -o ClearAllForwardings=yes "$REMOTE_HOST" \
        "mise exec -- herdr ${HERDR_UPDATE_ARGS[*]}"; then
      success "Forge Herdr updated"
    else
      error "Forge update failed. Existing sessions were not stopped."
      exit 1
    fi
  fi
fi

echo
info "Versions after update:"
[[ "$UPDATE_LOCAL" -eq 1 ]] && mise exec -- herdr --version
[[ "$UPDATE_REMOTE" -eq 1 ]] && ssh -o ClearAllForwardings=yes "$REMOTE_HOST" \
  'mise exec -- herdr --version'

echo
success "Done. Existing sessions were not explicitly stopped."
if [[ "$HANDOFF" -eq 1 ]]; then
  warn "If a session still reports the old version, reconnect it; do not run server stop unless you accept interrupting its panes."
fi
