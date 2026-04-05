#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# ─── colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${BOLD}==> $*${RESET}"; }
success() { echo -e "${GREEN}    ✓ $*${RESET}"; }
warn()    { echo -e "${YELLOW}    ! $*${RESET}"; }
error()   { echo -e "${RED}    ✗ $*${RESET}"; }
abort()   { error "$*"; exit 1; }

# ─── 1. detect OS ─────────────────────────────────────────────────────────────
info "Detecting OS..."
case "$(uname -s)" in
  Darwin) PLATFORM="osx" ;;
  Linux)
    grep -qi microsoft /proc/version 2>/dev/null && PLATFORM="wsl2" || PLATFORM="linux"
    ;;
  *) abort "Unsupported OS: $(uname -s)" ;;
esac
success "Platform: $PLATFORM"

# ─── 2. prerequisites ─────────────────────────────────────────────────────────
info "Installing prerequisites..."

if [[ "$PLATFORM" == "osx" ]]; then
  if ! xcode-select -p &>/dev/null; then
    warn "Xcode CLI tools not found — installing..."
    xcode-select --install
    echo "    Re-run this script after the Xcode CLI tools finish installing."
    exit 0
  fi
  success "Xcode CLI tools present"

  if ! command -v brew &>/dev/null; then
    warn "Homebrew not found — installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  success "Homebrew present"

  brew upgrade git &>/dev/null || brew install git
  success "git up to date"

  brew install stow &>/dev/null || true
  success "stow present"

else
  # Linux / WSL2
  info "Updating package lists..."
  sudo apt-get update -qq
  success "Package lists updated"

  sudo add-apt-repository -y ppa:git-core/ppa &>/dev/null
  sudo apt-get update -qq
  sudo apt-get install -y git stow &>/dev/null
  success "git and stow installed"

  if ! command -v brew &>/dev/null; then
    warn "Homebrew not found — installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
  success "Homebrew present"
fi

# ─── 3. stow personal dotfiles ────────────────────────────────────────────────
info "Stowing dotfiles ($PLATFORM)..."
cd "$DOTFILES_DIR"
for dir in git zsh shared "$PLATFORM"; do
  stow --restow "$dir"
  success "stowed $dir"
done

# ─── 4. install packages ──────────────────────────────────────────────────────
info "Installing packages via Brewfile..."
brew bundle --file="$DOTFILES_DIR/shared/Brewfile"
success "Packages installed"

# ─── 5. verify personal setup ─────────────────────────────────────────────────
info "Verifying personal setup..."

echo ""
echo -e "  ${BOLD}Git identity${RESET}"
GIT_NAME="$(git config --global user.name || true)"
GIT_EMAIL="$(git config --global user.email || true)"
[[ -n "$GIT_NAME" ]]  && success "name:  $GIT_NAME"  || warn "user.name not set"
[[ -n "$GIT_EMAIL" ]] && success "email: $GIT_EMAIL" || warn "user.email not set"

echo ""
echo -e "  ${BOLD}SSH — GitHub (critical)${RESET}"
SSH_RESULT="$(ssh -T git@github.com 2>&1 || true)"
if echo "$SSH_RESULT" | grep -q "successfully authenticated"; then
  success "GitHub SSH OK"
else
  error "GitHub SSH FAILED"
  warn "Open 1Password and make sure the SSH agent is enabled, then re-run."
  abort "Cannot continue — GitHub SSH is required to clone dotfiles-work."
fi

# ─── 6. clone and install dotfiles-work ───────────────────────────────────────
info "Setting up dotfiles-work..."
DOTFILES_WORK_REPO="git@github.com:WilberC/dotfiles-work.git"
DOTFILES_WORK_DIR="$HOME/Projects/Personal/dotfiles-work"

if [[ ! -d "$DOTFILES_WORK_DIR" ]]; then
  git clone "$DOTFILES_WORK_REPO" "$DOTFILES_WORK_DIR"
  success "Cloned dotfiles-work"
else
  success "dotfiles-work already present"
fi

bash "$DOTFILES_WORK_DIR/install.sh"

# ─── 7. post-install hints ────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}All done! Manual steps remaining:${RESET}"
echo ""
echo -e "  ${BOLD}All platforms${RESET}"
echo "    - Set up tool versions:  mise install"
echo "    - Sign into GitHub CLI:  gh auth login"
echo ""
if [[ "$PLATFORM" != "osx" ]]; then
  echo -e "  ${BOLD}Install manually (no Homebrew package available on Linux/WSL2):${RESET}"
  echo "    - Zed          https://zed.dev/docs/linux"
  echo "    - Claude Code  https://docs.anthropic.com/claude-code"
  echo ""
fi
