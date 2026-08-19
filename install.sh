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

  step "Aptfile packages"
  local dotfiles_dir
  dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  bash "$dotfiles_dir/scripts/install-aptfile.sh"
}

set_default_fish() {
  step "default shell → fish"

  if ! command -v fish &>/dev/null; then
    warn "fish not found — skipping shell change"
    return
  fi

  local fish_bin
  fish_bin=$(command -v fish)

  if [[ "$SHELL" == "$fish_bin" ]]; then
    success "fish already default shell"
    return
  fi

  if ! grep -qF "$fish_bin" /etc/shells; then
    info "Adding $fish_bin to /etc/shells..."
    echo "$fish_bin" | sudo tee -a /etc/shells > /dev/null
  fi

  info "Setting default shell to fish..."
  chsh -s "$fish_bin"
  success "Default shell set to fish — restart terminal to apply"
}

create_project_dirs() {
  step "project directories"
  local dotfiles_dir
  dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  bash "$dotfiles_dir/scripts/setup-dirs.sh"
}

stow_force() {
  local output
  local status
  local conflicts

  set +e
  output=$(stow --no-folding -n "$@" 2>&1)
  status=$?
  set -e
  conflicts=$(printf '%s\n' "$output" | sed -nE \
    -e 's/^[[:space:]]*\* existing target is not owned by stow: //p' \
    -e 's/^[[:space:]]*\* existing target is neither a link nor a directory: //p' \
    -e 's/^.*existing target is not owned by stow: //p')

  if [[ -n "$conflicts" ]]; then
    while IFS= read -r file; do
      warn "Removing conflicting path: ~/$file"
      rm -rf ~/"$file"
    done <<< "$conflicts"
  elif (( status != 0 )); then
    printf '%s\n' "$output" >&2
    return "$status"
  fi

  stow --no-folding "$@"
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

  # OpenSSH refuses to use an IdentityFile pointed at a .pub (the
  # agent-lookup-by-public-key mechanism) if its permissions are too open,
  # even though it's public key material. Git doesn't track full mode bits,
  # so this has to be reasserted on every install.
  if [[ -d ~/.config/ssh/pubs ]]; then
    chmod 600 ~/.config/ssh/pubs/*.pub 2>/dev/null || true
  fi
}

setup_zone_identifier_watcher() {
  step "Zone.Identifier watcher"

  if ! command -v systemctl &>/dev/null || [[ ! -d /run/systemd/system ]]; then
    warn "systemd is not running — skipping watcher auto-start"
    info "Start it manually anytime: clean-zone-watch ~"
    return
  fi

  if ! command -v inotifywait &>/dev/null; then
    warn "inotifywait not found — install Aptfile packages, then re-run install.sh"
    return
  fi

  info "Enabling watcher for $HOME..."
  systemctl --user daemon-reload
  systemctl --user enable --now watch-zone-identifiers.service
  success "Zone.Identifier watcher enabled"
}

setup_1password_ssh_agent_relay() {
  step "1Password SSH agent relay (WSL2)"

  if ! command -v systemctl &>/dev/null || [[ ! -d /run/systemd/system ]]; then
    warn "systemd is not running — skipping relay auto-start"
    info "Start it manually anytime: systemctl --user start 1password-ssh-agent-relay.service"
    return
  fi

  if ! command -v socat &>/dev/null; then
    info "Installing socat (WSL2-only dependency, bridges the Windows named-pipe agent into WSL)..."
    sudo apt update
    sudo apt install -y socat
  fi

  if ! command -v npiperelay.exe &>/dev/null && command -v powershell.exe &>/dev/null; then
    info "Installing npiperelay.exe via winget..."
    powershell.exe -NoProfile -Command "winget install --id jstarks.npiperelay --silent --accept-package-agreements --accept-source-agreements" \
      || warn "npiperelay install failed — install manually: winget install --id jstarks.npiperelay"
  fi

  info "Enabling relay service..."
  systemctl --user daemon-reload
  systemctl --user enable --now 1password-ssh-agent-relay.service
  success "1Password SSH agent relay enabled — native ssh now reaches the 1Password agent via ~/.1password/agent.sock"
}

setup_wsl_mirrored_networking() {
  step "WSL localhost access"

  if ! command -v powershell.exe &>/dev/null; then
    warn "powershell.exe not found — skipping mirrored networking setup"
    return
  fi

  local dotfiles_dir
  local script_path
  dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  script_path="$dotfiles_dir/scripts/setup-wsl-mirrored-networking.ps1"

  info "Enabling mirrored networking for Windows localhost access..."
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(wslpath -w "$script_path")"
  success "Mirrored networking configured — restart WSL when convenient to apply"
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

case "$CHOSEN" in
  wsl2)
    setup_wsl_mirrored_networking
    setup_zone_identifier_watcher
    setup_1password_ssh_agent_relay
    ;;
esac

case "$CHOSEN" in
  osx|linux|wsl2)
    set_default_fish
    ;;
esac

echo ""
success "Done. Dotfiles stowed for ${BOLD}$CHOSEN${RESET}."

echo ""
read -rp "$(echo -e "${BOLD}Set up work configs?${RESET} ${DIM}Requires SSH + 1Password agent [y/N]${RESET}: ")" SETUP_WORK
if [[ "${SETUP_WORK,,}" == "y" ]]; then
  bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/setup-work.sh"
else
  info "Skipped. Run manually anytime: ${BOLD}bash scripts/setup-work.sh${RESET}"
fi
