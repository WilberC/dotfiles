#!/usr/bin/env bash
set -euo pipefail

BOLD='\033[1m'
DIM='\033[2m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

info()    { echo -e "${CYAN}${BOLD}::${RESET} $*"; }
success() { echo -e "${GREEN}${BOLD}✓${RESET} $*"; }
warn()    { echo -e "${YELLOW}${BOLD}!${RESET} $*"; }
error()   { echo -e "${RED}${BOLD}✗${RESET} $*"; }

# --- detect ---
detect_os() {
  if [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
    echo "wsl2"
  elif [[ "$(uname)" == "Darwin" ]]; then
    echo "osx"
  elif [[ "$(uname)" == "Linux" ]]; then
    echo "linux"
  else
    echo "unknown"
  fi
}

DETECTED=$(detect_os)

echo ""
info "Detected system: ${BOLD}$DETECTED${RESET}"
echo ""
echo -e "  ${DIM}1)${RESET} wsl2"
echo -e "  ${DIM}2)${RESET} linux"
echo -e "  ${DIM}3)${RESET} osx"
echo ""
while true; do
  read -rp "$(echo -e "${BOLD}Select platform${RESET} ${DIM}[detected: $DETECTED]${RESET}: ")" INPUT
  CHOSEN="${INPUT:-$DETECTED}"

  case "$CHOSEN" in
    1) CHOSEN="wsl2" ;;
    2) CHOSEN="linux" ;;
    3) CHOSEN="osx" ;;
  esac

  if [[ "$CHOSEN" != "wsl2" && "$CHOSEN" != "linux" && "$CHOSEN" != "osx" ]]; then
    error "Unknown platform: ${BOLD}$CHOSEN${RESET}. Try again."
    continue
  fi

  if [[ "$CHOSEN" != "$DETECTED" ]]; then
    warn "Selected ${BOLD}$CHOSEN${RESET} but detected ${BOLD}$DETECTED${RESET}."
    read -rp "$(echo -e "${YELLOW}${BOLD}Continue?${RESET} ${DIM}[y/N]${RESET}: ")" CONFIRM
    [[ "${CONFIRM,,}" == "y" ]] || continue
  fi

  break
done

echo ""
success "Platform: ${BOLD}$CHOSEN${RESET}"
echo -e "${DIM}[TODO] Would install stow and stow packages for: $CHOSEN${RESET}"
