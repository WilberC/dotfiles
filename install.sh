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
step()    { echo -e "\n${BOLD}──── $* ────${RESET}"; }

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

install_xcode_clt() {
  if xcode-select -p &>/dev/null; then
    success "Xcode CLT already installed"
    return
  fi
  info "Installing Xcode Command Line Tools..."
  xcode-select --install
  # wait for user to finish the GUI installer
  echo -e "${DIM}Press Enter once the Xcode CLT installer completes...${RESET}"
  read -r
}

activate_brew() {
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_brew() {
  activate_brew
  if command -v brew &>/dev/null; then
    success "Homebrew already installed"
    return
  fi
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  activate_brew
  success "Homebrew installed"
}

install_stow_osx() {
  step "stow"
  if brew list stow &>/dev/null; then
    success "stow already installed"
  else
    info "Installing stow..."
    brew install stow
    success "stow installed"
  fi
}

install_stow_apt() {
  step "apt update & upgrade"
  info "Updating package lists..."
  sudo apt update

  info "Upgrading packages..."
  sudo apt upgrade -y
  success "System up to date"

  step "stow"
  if command -v stow &>/dev/null; then
    success "stow already installed"
  else
    info "Installing stow..."
    sudo apt install -y stow
    success "stow installed"
  fi
}

create_project_dirs() {
  step "project directories"
  local dotfiles_dir
  dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  bash "$dotfiles_dir/scripts/setup-dirs.sh"
}

stow_force() {
  local conflicts
  conflicts=$(stow -n "$@" 2>&1 | grep "existing target is not owned by stow:" | sed 's/.*existing target is not owned by stow: //')

  if [[ -n "$conflicts" ]]; then
    while IFS= read -r file; do
      warn "Removing conflicting file: ~/$file"
      rm -f ~/"$file"
    done <<< "$conflicts"
  fi

  stow "$@"
}

run_stow() {
  local platform="$1"
  local dotfiles_dir
  dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  step "stowing dotfiles"
  cd "$dotfiles_dir"

  info "Stowing: git shared"
  stow_force git shared
  success "git shared"

  info "Stowing: $platform"
  stow_force -d os -t ~ "$platform"
  success "$platform"
}

# --- platform select ---
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

# --- install ---
case "$CHOSEN" in
  osx)
    step "Xcode CLT"
    install_xcode_clt
    step "Homebrew"
    install_brew
    install_stow_osx
    ;;
  linux|wsl2)
    install_stow_apt
    ;;
esac

create_project_dirs
run_stow "$CHOSEN"

echo ""
success "Done. Dotfiles stowed for ${BOLD}$CHOSEN${RESET}."

echo ""
read -rp "$(echo -e "${BOLD}Set up work configs?${RESET} ${DIM}Requires SSH + 1Password agent [y/N]${RESET}: ")" SETUP_WORK
if [[ "${SETUP_WORK,,}" == "y" ]]; then
  bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/setup-work.sh"
else
  info "Skipped. Run manually anytime: ${BOLD}bash scripts/setup-work.sh${RESET}"
fi
